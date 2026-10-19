"""Write RDR2 UI scenes and flow blocks (RBF XML) from Python, for codexcli fromxml.

    from uiscene import Scene
    s = Scene('MyHud')                                   # binds to ScriptDatastoreRoot.MyHud.*
    s.add(s.text('TXT_Title', 'title', 'HUD_TEXT_SUB_HEADER', h='HALIGN_CENTER', t=40))
    s.write('src/my_hud_scene.rbf.xml')
    flow('my_hud_flow', 'my_hud_scene', 'src/my_hud_flow.rbf.xml')

Layout keywords of every element: h / v (HALIGN_* / VALIGN_*), w / ht (fixed size, else content-sized),
l / t / r / b (margins). Bound paths are relative to the scene's root container.
"""

# Colour bindings take an int; these are the colours it maps to (index = value).
PALETTE = ['COLOR_WHITE', 'COLOR_BLUE', 'COLOR_YELLOW', 'COLOR_RED', 'COLOR_GREY', 'COLOR_GOLD', 'COLOR_GREEN',
           'COLOR_GREYMID', 'COLOR_BLACK']


def _indent(text, n):
    return '\n'.join(' ' * n + l if l else l for l in text.split('\n'))


def _layout(h='HALIGN_LEFT', v='VALIGN_TOP', w=None, ht=None, l=0, t=0, r=0, b=0):
    p = [f'<horizontalAlignment>{h}</horizontalAlignment>', f'<verticalAlignment>{v}</verticalAlignment>',
         f'<widthContentMode>{"CONTENT_MODE_RAW" if w is not None else "CONTENT_MODE_AUTO"}</widthContentMode>',
         f'<heightContentMode>{"CONTENT_MODE_RAW" if ht is not None else "CONTENT_MODE_AUTO"}</heightContentMode>']
    if w is not None:
        p.append(f'<width value="{w}" />')
    if ht is not None:
        p.append(f'<height value="{ht}" />')
    for k, val in (('leftMargin', l), ('rightMargin', r), ('topMargin', t), ('bottomMargin', b)):
        if val:
            p.append(f'<{k} value="{val}" />')
    return ('<UseLayoutEngine value="True" />\n<LayoutParams type="rage__LayoutParamInstanceAsset">\n <params>\n'
            + '\n'.join('  ' + x for x in p) + '\n </params>\n</LayoutParams>')


def _special(kind, inner):
    return ('<SpecializedLayoutParams>\n <Item type="rage__SpecializedParamInstanceAsset">\n'
            f'  <params type="{kind}">\n' + _indent(inner, 3) + '\n  </params>\n </Item>\n</SpecializedLayoutParams>')


def _color_converter(default):
    items = '\n'.join(f'  <Item key="{i}">{c}</Item>' for i, c in enumerate(PALETTE))
    return (f'<Converter type="rage__fwuiIntHashStringDictionaryConversion">\n <Default>{default}</Default>\n'
            f' <Dictionary>\n{items}\n </Dictionary>\n</Converter>')


def _item(kind, name, body):
    return f'<Item type="{kind}">\n <Name>{name}</Name>\n' + _indent('\n'.join(x for x in body if x), 1) + '\n</Item>'


def _children(kids):
    return '<Children>\n' + _indent('\n'.join(kids), 1) + '\n</Children>'


class Scene:
    def __init__(self, root, attach='safeframe_hud'):
        self.root, self.attach, self.kids, self.paths = root, attach, [], set()

    def _bindings(self, items):
        out = []
        for member, path, conv in items:
            if not path:
                continue
            self.paths.add(path)
            x = (f'<Item>\n <MemberName>{member}</MemberName>\n <Setup>\n'
                 f'  <Path>ScriptDatastoreRoot.{self.root}.{path}</Path>\n  <PathType>PATH_ABSOLUTE</PathType>\n </Setup>\n')
            out.append(x + (_indent(conv, 1) + '\n' if conv else '') + '</Item>')
        return '<MemberBindings>\n' + _indent('\n'.join(out), 1) + '\n</MemberBindings>' if out else ''

    # ---- elements
    def text(self, name, path, style, align='LEFT', color=None, color_path=None, visible=None, multiline=False, **lay):
        """UIText showing the string at `path`; colour fixed (color) or an int at color_path (PALETTE index)."""
        b = [('RawText', path, None),
             ('Color', color_path, _color_converter(color or 'COLOR_WHITE') if color_path else None),
             ('Visible', visible, None)]
        return _item('UIText', name, [_layout(**lay), f'<Style>{style}</Style>', f'<HAlign>{align}</HAlign>',
                                      '<ParagraphStyle>MULTILINE</ParagraphStyle>' if multiline else '',
                                      f'<Color>{color}</Color>' if color and not color_path else '', self._bindings(b)])

    def image(self, name, txd, texture, style=None, visible=None, **lay):
        """UIImage stretched over its box. Its texture dictionary must be in the flow's resources."""
        return _item('UIImage', name, [f'<TextureDictionary>{txd}</TextureDictionary>', f'<Texture>{texture}</Texture>',
                                       f'<Style>{style}</Style>' if style else '', _layout(**lay),
                                       _special('rage__fwuiStretchParams', '<Stretch>FILL</Stretch>'),
                                       self._bindings([('Visible', visible, None)])])

    def ink(self, name, **lay):
        """The dark brush background of the game's menus (generic_textures / INKROLLER_1A)."""
        lay.setdefault('h', 'HALIGN_STRETCH')
        lay.setdefault('v', 'VALIGN_STRETCH')
        return self.image(name, 'generic_textures', 'INKROLLER_1A', 'INK_BACKGROUND_COLOR', **lay)

    def meter(self, name, path, fill='COLOR_WHITE', fill_path=None, track='COLOR_GREYDARK', **lay):
        """A bar; `path` is a float 0..1."""
        sf = ''.join(f' <Item type="SF_String">\n  <Name>{k}</Name>\n  <Value>{v}</Value>\n </Item>\n' for k, v in (
            ('trackDictionary', 'generic_textures'), ('trackTexture', 'MENU_BAR'),
            ('fillDictionary', 'generic_textures'), ('fillTexture', 'MENU_BAR')))
        b = [('Value', path, None), ('FillColor', fill_path, _color_converter(fill) if fill_path else None)]
        return _item('UIMeter', name, [
            _layout(**lay), '<BehaviorSet>\n <Behaviors>\n  <Item type="uiDisplayObjectBehavior">\n'
            '   <SymbolName>FCMeter</SymbolName>\n  </Item>\n </Behaviors>\n</BehaviorSet>',
            f'<TrackColor>{track}</TrackColor>', f'<FillColor>{fill}</FillColor>', '<Minimum value="0" />',
            '<Maximum value="1" />', '<Value value="0" />', '<SFData>\n' + sf + '</SFData>', self._bindings(b)])

    def panel(self, name, kids, visible=None, **lay):
        """Children placed by their own alignment and margins."""
        return _item('UIPanel', name, [_layout(**lay), self._bindings([('Visible', visible, None)]), _children(kids)])

    def stack(self, name, kids, vertical=True, visible=None, **lay):
        """Children one after another."""
        o = 'PANEL_ORIENT_VERTICAL' if vertical else 'PANEL_ORIENT_HORIZONTAL'
        return _item('UIStackPanel', name, [_layout(**lay), _special('rage__StackPanelParams', f'<orientation>{o}</orientation>'),
                                            self._bindings([('Visible', visible, None)]), _children(kids)])

    def add(self, *elements):
        self.kids += elements

    # ---- output
    def xml(self):
        return ('<?xml version="1.0" encoding="UTF-8"?>\n<UIMovieView>\n'
                f' <Name>{self.root}Root</Name>\n <MovieFileName>UIOBJECT_SCENE_GENERIC</MovieFileName>\n'
                f' <UseLayoutEngine value="True" />\n <LayoutAttachmentOverride>{self.attach}</LayoutAttachmentOverride>\n'
                + _indent(_layout('HALIGN_STRETCH', 'VALIGN_STRETCH').split('\n', 1)[1], 1) + '\n'
                + _indent(self._bindings([('Visible', 'visible', None)]), 1) + '\n'
                + _indent(_children(self.kids), 1) + '\n</UIMovieView>\n')

    def write(self, path):
        with open(path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(self.xml())


def flow(flow_id, scene, path, txds=('generic_textures',)):
    """A flow block that loads the texture dictionaries and the scene, then shows the scene."""
    res = ''.join(f'    <Item type="rage__fwuiTextureDictionaryDependencyResource">\n     <Name>{t}</Name>\n    </Item>\n'
                  for t in txds)
    xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<rage__fwuiFlowBlock>
 <ID>{flow_id}</ID>
 <EntryPoints>
  <Item>
   <ID>default_entry_point</ID>
   <Target>{scene}_host</Target>
  </Item>
 </EntryPoints>
 <ExitPoints>
  <Item>
   <ID>exit_to_game</ID>
  </Item>
 </ExitPoints>
 <FlowRoot>
  <ID>resource_load</ID>
  <State type="rage__StateResourceLoader">
   <Resources>
{res}    <Item type="UIObjectSceneStreamingDependencyResource">
     <Name>{scene}</Name>
    </Item>
   </Resources>
  </State>
  <Children>
   <Item>
    <ID>{scene}_host</ID>
    <State type="StateUIObjectStreamedSceneHost">
     <SceneName>{scene}</SceneName>
     <GCOnRemove value="True" />
    </State>
   </Item>
  </Children>
 </FlowRoot>
</rage__fwuiFlowBlock>
'''
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(xml)
