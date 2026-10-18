"""Collect the English text of every label key the UI files use.

usage: python -I labels.py <lang-xml-dir> <ui-xml-dir> <catalog.json>
<lang-xml-dir>/L0 is the base language pack, L1 the update that overrides it (codexcli xml of .yldb files).
Adds catalog['labels'] = {KEY: text} and writes the catalog back.
"""
import sys, os, re, json

LANG, UI, CAT = sys.argv[1:4]


def joaat(s):
    h = 0
    for ch in s.lower().encode('utf-8'):
        h = (h + ch) & 0xFFFFFFFF
        h = (h + (h << 10)) & 0xFFFFFFFF
        h ^= h >> 6
    h = (h + (h << 3)) & 0xFFFFFFFF
    h ^= h >> 11
    h = (h + (h << 15)) & 0xFFFFFFFF
    return h


ITEM = re.compile(r'<Item hash="(?:[^"]*?_)?0x([0-9a-fA-F]{8})">\s*<Text>(.*?)</Text>', re.S)
text = {}
for layer in ('L0', 'L1'):
    d = os.path.join(LANG, layer)
    if not os.path.isdir(d):
        continue
    for f in os.listdir(d):
        s = open(os.path.join(d, f), encoding='utf-8', errors='replace').read()
        for h, t in ITEM.findall(s):
            text[int(h, 16)] = t.replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"').replace('&apos;', "'").replace('&amp;', '&')
print('strings', len(text))

# every upper-case token in the UI files that names a string
keys = set()
TOKEN = re.compile(r'[>"]([A-Z][A-Z0-9_]{2,80})[<"]')
for dp, dn, fn in os.walk(UI):
    for f in fn:
        for k in TOKEN.findall(open(os.path.join(dp, f), encoding='utf-8', errors='replace').read()):
            keys.add(k)
labels = {k: text[joaat(k)] for k in sorted(keys) if joaat(k) in text}
print('ui keys', len(keys), 'with text', len(labels))

cat = json.load(open(CAT, encoding='utf-8'))
cat['labels'] = labels
json.dump(cat, open(CAT, 'w', encoding='utf-8'), default=list)
for k in ('SATCHEL_TITLE', 'IB_BACK', 'IB_SELECT', 'CATALOG_MISC_DOLLAR_SYMBOL', 'MENU_FAST_TRAVEL'):
    print(k, '=>', labels.get(k))
