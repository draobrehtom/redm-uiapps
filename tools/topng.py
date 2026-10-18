import sys, os, json
from PIL import Image
import struct


def read_a8(path):
    # uncompressed alpha-only DDS (DDPF_ALPHA, 8 bits): white with that alpha
    b = open(path, 'rb').read()
    h, w = struct.unpack_from('<II', b, 12)
    flags, = struct.unpack_from('<I', b, 80)
    bits, = struct.unpack_from('<I', b, 88)
    if not (flags & 0x2) or bits != 8:
        raise ValueError('not A8')
    a = Image.frombytes('L', (w, h), b[128:128 + w * h])
    im = Image.new('RGBA', (w, h), (255, 255, 255, 255))
    im.putalpha(a)
    return im
cat = json.load(open(sys.argv[1]))
src, dst = sys.argv[2], sys.argv[3]
os.makedirs(dst, exist_ok=True)
ok = fail = 0; fails = {}; sizes = {}
for txd, texs in cat['textures'].items():
    d = os.path.join(src, txd.lower())
    if not os.path.isdir(d): continue
    for t in texs:
        p = os.path.join(d, t.lower() + '.dds')
        if not os.path.exists(p): continue
        try:
            try:
                im = Image.open(p); im.load()
            except Exception:
                im = read_a8(p)
            w, h = im.size
            sizes[(txd + '/' + t).lower()] = [w, h]
            im = im.convert('RGBA'); im.thumbnail((256, 256))
            im.save(os.path.join(dst, (txd + '__' + t).lower() + '.png'), optimize=True)
            ok += 1
        except Exception as ex:
            fail += 1; fails[str(ex)[:60]] = fails.get(str(ex)[:60], 0) + 1
json.dump(sizes, open(os.path.join(dst, '..', 'texsizes.json'), 'w'))
print(ok, fail, fails)
