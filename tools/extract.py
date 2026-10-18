"""Build a JSON catalog of the RDR2 UI layer from codexcli XML output.

usage: python -I extract.py <xml-root> <out.json>
"""
import sys, os, re, json, collections
import xml.etree.ElementTree as ET

ROOT, OUT = sys.argv[1], sys.argv[2]


def joaat(s):
    h = 0
    for c in s.lower().encode('utf-8'):
        h = (h + c) & 0xFFFFFFFF
        h = (h + (h << 10)) & 0xFFFFFFFF
        h ^= h >> 6
    h = (h + (h << 3)) & 0xFFFFFFFF
    h ^= h >> 11
    h = (h + (h << 15)) & 0xFFFFFFFF
    return h


def signed(h):
    return h - 0x100000000 if h >= 0x80000000 else h


def hashinfo(s):
    if s is None:
        return None
    m = re.fullmatch(r'0x([0-9a-fA-F]{1,8})', s)
    h = int(m.group(1), 16) if m else joaat(s)
    return {'name': None if m else s, 'hex': '0x%08X' % h, 'int': signed(h)}


def load(path):
    txt = open(path, encoding='utf-8', errors='replace').read()
    # CodeX writes converter dictionary values as <>X</>
    txt = txt.replace('<>', '<v>').replace('</>', '</v>')
    txt = re.sub(r'<(/?)(\d)', r'<\1_\2', txt)
    return ET.fromstring(txt)


def rel(p):
    return os.path.relpath(p, ROOT).replace('\\', '/').replace('.ymt.xml', '').replace('.meta.xml', '').replace('.xml', '')


def text(e, tag):
    c = e.find(tag)
    return c.text.strip() if c is not None and c.text and c.text.strip() else None


files = {}
errors = []
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if f.endswith('.xml'):
            p = os.path.join(dp, f)
            try:
                files[rel(p)] = load(p)
            except Exception as ex:
                errors.append((rel(p), str(ex)))

# ---------- hashed file names: the hash is joaat of the path inside its folder ----------
renamed = {}
hashed = {n: n.split('/', 1) for n in files if re.fullmatch(r'0x[0-9a-f]{1,8}', n.split('/')[-1])}
if hashed:
    cands = set()
    for root in files.values():
        for e in root.iter():
            t = (e.text or '').strip()
            if t and len(t) < 160 and ' ' not in t:
                cands.add(t)
    byhash = {}
    for t in cands:
        for v in (t, t.split('/', 1)[1] if t.startswith(('screens/', 'widgets/', 'flow/')) else None):
            if v:
                byhash.setdefault(joaat(v), v)
    for n, (folder, rest) in hashed.items():
        h = int(rest.split('/')[-1], 16)
        real = byhash.get(h)
        if real:
            new = folder + '/' + real.lower()
            if new not in files:
                files[new] = files.pop(n)
                renamed[n] = new

cat = {'stats': {}, 'apps': {}, 'flows': {}, 'events': {}, 'templates': [], 'datastore': {},
       'hudslots': [], 'hudcontexts': {}, 'scenes': {}, 'textures': {}, 'inputcontexts': [], 'errors': errors}

# ---------- apps (launch conditions) ----------
lc = files.get('applaunch/launchconditions')
if lc is not None:
    for it in lc.find('LaunchMap'):
        key = it.get('key')
        blocked = sorted({a.text for a in it.iter('AppID') if a.text})
        cat['apps'][key] = {'hash': hashinfo(key), 'blockedBy': blocked}

# ---------- flows ----------
def walk_states(node, path, out, fname):
    for it in node.iter('Item'):
        pass


for name, root in files.items():
    if root.tag != 'rage__fwuiFlowBlock':
        continue
    fid = text(root, 'ID') or name
    fl = {'file': name, 'id': fid, 'hash': hashinfo(fid), 'entries': [], 'exits': [], 'scenes': [], 'subflows': [],
          'contexts': [], 'resources': [], 'events': [], 'states': 0, 'templates': []}
    ep = root.find('EntryPoints')
    if ep is not None:
        for it in ep:
            eid = text(it, 'ID')
            if eid:
                fl['entries'].append({'id': eid, 'target': text(it, 'Target'), 'hash': hashinfo(eid)})
    xp = root.find('ExitPoints')
    if xp is not None:
        fl['exits'] = [text(it, 'ID') for it in xp if text(it, 'ID')]
    for st in root.iter('State'):
        fl['states'] += 1
        sn = text(st, 'SceneName')
        if sn:
            fl['scenes'].append(sn)
        nm = text(st, 'Name')
        if nm and st.find('Resources') is None:
            fl['subflows'].append(nm)
        cx = text(st, 'Context')
        if cx:
            fl['contexts'].append(cx)
        ch = text(st, 'Channel')
        ev = st.find('Event')
        if ch and ev is not None:
            fl['events'].append({'channel': ch, 'type': text(ev, 'Type'), 'param': text(ev, 'HashParameter')})
    for res in root.iter('Resources'):
        for it in res:
            n = text(it, 'Name')
            t = it.find('Template')
            if t is not None and text(t, 'Id'):
                keys = [k.get('key') for k in (t.find('PropertyKeys') or [])]
                cat['templates'].append({'alias': text(t, 'Id'), 'widget': n, 'flow': fid, 'keys': keys,
                                         'hash': hashinfo(text(t, 'Id'))})
                fl['templates'].append(text(t, 'Id'))
            elif n:
                fl['resources'].append(n)
    for k in ('scenes', 'subflows', 'contexts', 'resources'):
        fl[k] = sorted(set(fl[k]))
    cat['flows'][fid] = fl

# ---------- scene mounts: which host scene a scene is shown inside, and where ----------
cat['mounts'] = {}


def mounts(item, host, flow):
    st = item.find('State')
    sn = text(st, 'SceneName') if st is not None else None
    if sn:
        m = cat['mounts'].setdefault(sn, [])
        e = {'host': host, 'parentPath': text(st, 'ParentPath'), 'flow': flow}
        if e not in m:
            m.append(e)
        host = sn
    ch = item.find('Children')
    if ch is not None:
        for it in ch:
            mounts(it, host, flow)


for name, root in files.items():
    if root.tag == 'rage__fwuiFlowBlock' and root.find('FlowRoot') is not None:
        mounts(root.find('FlowRoot'), None, text(root, 'ID') or name)

# ---------- script events (everywhere) ----------
def add_event(ch, param, typ, src, kind):
    if not ch:
        return
    e = cat['events'].setdefault(ch, {'hash': hashinfo(ch), 'params': {}})
    p = e['params'].setdefault(param or '(none)', {'hash': hashinfo(param) if param else None, 'types': set(), 'sources': set()})
    if typ:
        p['types'].add(typ)
    p['sources'].add(src)


for name, root in files.items():
    for op in root.iter('ScriptEventOp'):
        add_event(text(op, 'EventChannel'), text(op, 'HashParameter'), text(op, 'Type'), name, 'op')
    for st in root.iter():
        ch = text(st, 'Channel')
        ev = st.find('Event')
        if ch and ev is not None and len(ev):
            add_event(ch, text(ev, 'HashParameter'), text(ev, 'Type'), name, 'state')
for e in cat['events'].values():
    for p in e['params'].values():
        p['types'] = sorted(p['types'])
        p['sources'] = sorted(p['sources'])

# ---------- datastore paths ----------
ds = collections.defaultdict(lambda: {'refs': set(), 'members': set()})
for name, root in files.items():
    pmap = {c: p for p in root.iter() for c in p}
    for parent in root.iter():
        pt = parent.find('PathType')
        pa = parent.find('Path')
        if pt is None or pa is None:
            continue
        if pt.text != 'PATH_ABSOLUTE':
            continue
        if pa.text and pa.text.strip():
            path = pa.text.strip()
        else:
            path = '.'.join((v.text or '').strip() for v in pa.findall('pathElements/Item/v'))
        if not path:
            continue
        if path.startswith('ScriptDatastoreRoot.'):
            path = path[len('ScriptDatastoreRoot.'):]
        d = ds[path]
        d['refs'].add(name)
        # what consumes it: a member binding (Text, Visible ...), an animation behaviour or a binding context
        holder = pmap.get(parent)
        if holder is not None:
            mn = text(holder, 'MemberName')
            if mn:
                d['members'].add(mn)
            elif text(holder, 'Animation'):
                d['members'].add('anim')
            elif parent.tag == 'BindingContext':
                d['members'].add('context')
            elif parent.tag in ('BindingSetup', 'Setup'):
                d['members'].add(parent.tag)
for p, d in ds.items():
    cat['datastore'][p] = {'refs': sorted(d['refs']), 'members': sorted(d['members'])}

# datastore entries defined by the game (templates/credits/help)
cat['dsentries'] = {}
for name, root in files.items():
    if root.tag == 'rage__fwuiDatastoreEntry':
        cat['dsentries'][name] = text(root, 'ID')

# ---------- HUD visibility ----------
hv = files.get('hudvisibility/visibilityconditions')


def hud(node, depth, parent):
    slot = text(node, 'SlotType')
    ctx_hide, ctx_show, args = set(), set(), set()
    es = node.find('EvaluationSet')
    if es is not None:
        for it in es:
            rs = text(it, 'ResultState') or ''
            for c in it.iter('Context'):
                if c.text:
                    (ctx_hide if 'HIDE' in rs else ctx_show).add(c.text)
            for a in it.iter('Arg'):
                if a.text:
                    args.add(a.text)
    cat['hudslots'].append({'slot': slot, 'depth': depth, 'parent': parent, 'default': text(node, 'DefaultState'),
                            'hideCtx': sorted(ctx_hide), 'showCtx': sorted(ctx_show), 'args': sorted(args)})
    for c in ctx_hide | ctx_show:
        cat['hudcontexts'].setdefault(c, {'hash': hashinfo(c), 'hides': [], 'shows': []})
        cat['hudcontexts'][c]['hides' if c in ctx_hide else 'shows'].append(slot)
    ch = node.find('Children')
    if ch is not None:
        for it in ch:
            hud(it, depth + 1, slot)


if hv is not None:
    hud(hv, 0, None)
for name, root in files.items():
    for c in root.iter('Context'):
        if c.text and c.text.startswith('HUD_CTX_') and c.text not in cat['hudcontexts']:
            cat['hudcontexts'][c.text] = {'hash': hashinfo(c.text), 'hides': [], 'shows': []}

cat['inputcontexts'] = sorted(n.split('/')[-1] for n in files if n.startswith('inputcontexts/'))

# ---------- scenes / widgets: UI element tree for previews ----------
UI_TAGS = {'UIPanel', 'UIGrid', 'UIStackPanel', 'UIImage', 'UIText', 'UIMovieView', 'UIRectangle', 'UIScrollPanel'}


def num(v):
    # signed values (negative margins) are written as unsigned 32-bit numbers
    try:
        f = float(v)
    except ValueError:
        return None
    if f >= 2 ** 31 and f < 2 ** 32:
        f -= 2 ** 32
    return f


def lp(node):
    out = {}
    p = node.find('LayoutParams/params')
    if p is not None:
        for k in ('horizontalAlignment', 'verticalAlignment', 'widthContentMode', 'heightContentMode'):
            v = text(p, k)
            if v:
                out[k[:2] if k in ('horizontalAlignment',) else k] = v
        for k in ('width', 'height', 'leftMargin', 'rightMargin', 'topMargin', 'bottomMargin', 'row', 'column', 'rowSpan', 'columnSpan'):
            e = p.find(k)
            if e is not None and e.get('value') is not None:
                v = num(e.get('value'))
                if v is not None:
                    out[k] = v
    sp = node.find('SpecializedLayoutParams')
    if sp is not None:
        for it in sp.iter('params'):
            # a grid child's cell is in its specialized params
            for k in ('row', 'column', 'rowSpan', 'columnSpan'):
                e = it.find(k)
                if e is not None and e.get('value') is not None and num(e.get('value')) is not None:
                    out[k] = num(e.get('value'))
            for k in ('orientation', 'Stretch'):
                v = text(it, k)
                if v:
                    out[k] = v
            for k in ('rows', 'columns'):
                r = it.find(k)
                if r is not None:
                    out[k] = [{'size': text(x, 'size') or (x.find('size').get('value') if x.find('size') is not None else None),
                               'type': text(x, 'type')} for x in r]
    return out


def pathof(pe):
    if pe is None:
        return None
    if pe.text and pe.text.strip():
        return pe.text.strip()
    return '.'.join((v.text or '').strip() for v in pe.findall('pathElements/Item/v')) or None


def strip_root(p):
    return p[len('ScriptDatastoreRoot.'):] if p and p.startswith('ScriptDatastoreRoot.') else p


DERIVED = collections.defaultdict(set)


PFX = [('IMG', 'UIImage'), ('TXT', 'UIText'), ('TEXT', 'UIText'), ('GRD', 'UIGrid'), ('GRID', 'UIGrid'), ('STACK', 'UIStackPanel'),
       ('STK', 'UIStackPanel'), ('VB', 'UIStackPanel'), ('HB', 'UIStackPanel'), ('REC', 'UIRectangle'), ('RECT', 'UIRectangle'), ('MV', 'UIMovieView'), ('PAN', 'UIPanel')]


def infer(node):
    if node.find('TextureDictionary') is not None or node.find('Texture') is not None:
        return 'UIImage'
    if node.find('Text') is not None or node.find('Font') is not None or node.find('ParagraphStyle') is not None:
        return 'UIText'
    sp = node.find('SpecializedLayoutParams')
    if sp is not None:
        if sp.find('.//columns') is not None or sp.find('.//rows') is not None:
            return 'UIGrid'
        if sp.find('.//orientation') is not None:
            return 'UIStackPanel'
    n = (text(node, 'Name') or '').upper()
    for p, t in PFX:
        if n.startswith(p + '_'):
            return t
    for mb in node.findall('MemberBindings/Item'):
        if text(mb, 'MemberName') in ('Text', 'RawText'):
            return 'UIText'
        if text(mb, 'MemberName') in ('Texture', 'TextureDictionary'):
            return 'UIImage'
    return 'UIPanel'


def elem(node, scene, depth=0, prefix=None):
    d = {'n': text(node, 'Name'), 't': node.tag if node.tag != 'Item' else infer(node)}
    # a Context behaviour or an absolute BindingContext sets the base for local bindings below
    for b in node.findall('BehaviorSet/Behaviors/Item'):
        c = b.find('Context')
        if c is not None and pathof(c.find('Path')):
            cp = pathof(c.find('Path'))
            if text(c, 'PathType') == 'PATH_ABSOLUTE' or cp.startswith('ScriptDatastoreRoot'):
                prefix = strip_root(cp)
            elif prefix:
                prefix = prefix + '.' + cp
    bc0 = node.find('BindingContext')
    if bc0 is not None and pathof(bc0.find('Path')):
        p0 = pathof(bc0.find('Path'))
        if text(bc0, 'PathType') == 'PATH_ABSOLUTE':
            prefix = strip_root(p0)
        elif prefix:
            prefix = prefix + '.' + p0
    if prefix:
        d['pre'] = prefix
    d.update(lp(node))
    for k in ('TextureDictionary', 'Texture', 'Color', 'Text', 'Style', 'Font', 'ParagraphStyle', 'HAlign', 'AutoSize'):
        v = text(node, k)
        if v:
            d[k] = v
    for k in ('Alpha', 'FontSize', 'Visible', 'FlipHorizontal', 'FlipVertical', 'Rotation'):
        e = node.find(k)
        if e is not None and e.get('value') is not None:
            d[k] = e.get('value')
    if text(node, 'TextureDictionary'):
        cat['textures'].setdefault(text(node, 'TextureDictionary'), set()).add(text(node, 'Texture') or '')
    binds = []
    for mb in node.findall('MemberBindings/Item'):
        s = mb.find('Setup')
        if s is not None:
            bp = pathof(s.find('Path')); pt = (text(s, 'PathType') or '').replace('PATH_', '')
            binds.append({'m': text(mb, 'MemberName'), 'p': bp, 'pt': pt})
            if pt in ('LOCAL', 'RELATIVE') and prefix and bp and not bp.startswith('^'):
                DERIVED[prefix + '.' + bp].add((scene, text(mb, 'MemberName')))
    bs = node.find('BehaviorSet/Behaviors')
    if bs is not None:
        for b in bs:
            s = b.find('BindingSetup')
            if s is not None and text(s, 'PathType') == 'PATH_RELATIVE' and prefix and text(s, 'Path'):
                DERIVED[prefix + '.' + text(s, 'Path')].add((scene, 'anim'))
            if s is not None:
                binds.append({'m': 'anim:' + (text(b, 'Animation') or text(b, 'Name') or ''), 'p': text(s, 'Path'), 'pt': (text(s, 'PathType') or '').replace('PATH_', '')})
            if b.find('ItemCreator') is not None and b.find('BindingContext') is not None:
                lpth = pathof(b.find('BindingContext/Path'))
                if lpth:
                    d['list'] = strip_root(lpth) if text(b.find('BindingContext'), 'PathType') != 'PATH_RELATIVE' or not prefix else prefix + '.' + lpth
            sl = text(b, 'SlotType')
            if sl:
                d['slot'] = sl
            sym = text(b, 'SymbolName')
            if sym and sym != 'fcContainer':
                d.setdefault('sym', []).append(sym)
    bc = node.find('BindingContext')
    if bc is not None and text(bc, 'Path'):
        d['ctx'] = {'p': text(bc, 'Path'), 'pt': (text(bc, 'PathType') or '').replace('PATH_', '')}
    if binds:
        d['b'] = binds
    tpl = node.find('Instancing')
    if tpl is not None:
        d['inst'] = [text(i, 'Type') for i in tpl if text(i, 'Type')]
    kids = []
    ch = node.find('Children')
    if ch is not None and depth < 40:
        for it in ch:
            kids.append(elem(it, scene, depth + 1, prefix))
    if kids:
        d['c'] = kids
    tn = text(node, 'Template') or text(node, 'TemplateName')
    if tn:
        d['tpl'] = tn
    return d


cat['ui'] = {}
for name, root in files.items():
    if name.split('/')[0] in ('screens', 'widgets', 'startup_data') and root.tag.startswith('UI'):
        try:
            cat['ui'][name] = elem(root, name)
        except RecursionError:
            pass

# instanced widgets inherit the binding context of the element that instances them
WIDX = {}
for n in files:
    if n.startswith(('widgets/', 'screens/')):
        WIDX.setdefault(n.split('/')[-1].lower(), n)


TALIAS = {}
for t in cat['templates']:
    TALIAS.setdefault(t['alias'].lower(), 'widgets/' + t['widget'].lower())


def inst_pass(tree, scene, seen):
    pre = tree.get('pre')
    for t in tree.get('inst', []) or []:
        w = TALIAS.get(t.lower()) if TALIAS.get(t.lower()) in files else WIDX.get(t.lower())
        if w and pre and (w, pre) not in seen and len(seen) < 400:
            seen.add((w, pre))
            sub = elem(files[w], scene + ' > ' + w, 0, pre)
            inst_pass(sub, scene, seen)
    for c in tree.get('c', []):
        inst_pass(c, scene, seen)


for n, t in list(cat['ui'].items()):
    inst_pass(t, n, set())

for p, refs in DERIVED.items():
    e = cat['datastore'].setdefault(p, {'refs': [], 'members': []})
    e['refs'] = sorted(set(e['refs']) | {r for r, m in refs})
    e['members'] = sorted(set(e['members']) | {m for r, m in refs if m})
    e['derived'] = True
cat['stats']['datastorePaths'] = len(cat['datastore'])
for k in list(cat['textures']):
    cat['textures'][k] = sorted(t for t in cat['textures'][k] if t)

cat['renamed'] = renamed
cat['stats'] = {'files': len(files), 'renamedHashes': len(renamed), 'errors': len(errors), 'flows': len(cat['flows']), 'apps': len(cat['apps']),
                'channels': len(cat['events']), 'eventParams': sum(len(e['params']) for e in cat['events'].values()),
                'templates': len(cat['templates']), 'datastorePaths': len(cat['datastore']),
                'hudSlots': len(cat['hudslots']), 'hudContexts': len(cat['hudcontexts']), 'ui': len(cat['ui']),
                'txds': len(cat['textures'])}
json.dump(cat, open(OUT, 'w', encoding='utf-8'), indent=None, default=list)
print(json.dumps(cat['stats'], indent=1))
for e in errors[:10]:
    print('ERR', e)

# ---------- colors + styles ----------
colors = {}
for m in re.finditer(r'<Col key="([^"]+)"\s+value="0x([0-9a-fA-F]{8})"', open(os.path.join(ROOT, 'colors.xml'), encoding='utf-8', errors='replace').read()):
    v = m.group(2).lower()  # 0xAABBGGRR
    colors[m.group(1)] = '#' + v[6:8] + v[4:6] + v[2:4] + v[0:2]
styles = {}
for name, root in files.items():
    if root.tag != 'rage__fwuiStyleCollection':
        continue
    for it in root.find('Styles') or []:
        s = {}
        for pr in it.iter():
            for k in ('Color', 'Font', 'ParagraphStyle'):
                if pr.tag == k and pr.text:
                    s[k] = pr.text
            for k in ('FontSize', 'Alpha'):
                if pr.tag == k and pr.get('value'):
                    s[k] = pr.get('value')
        styles[it.get('key')] = s
cat['colors'] = colors
cat['styles'] = styles
json.dump(cat, open(OUT, 'w', encoding='utf-8'), indent=None, default=list)
print('colors', len(colors), 'styles', len(styles))
