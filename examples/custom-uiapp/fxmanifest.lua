fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'A UI app of its own: a new flow block and a new scene, streamed from this resource'

client_script 'client.lua'

-- stream/luman_uiapp_flow.ymt  and  stream/luman_uiapp_scene.ymt are built from src/*.rbf.xml with codexcli:
--   codexcli fromxml src\luman_uiapp_flow.rbf.xml stream\luman_uiapp_flow.ymt
--   codexcli fromxml src\luman_uiapp_scene.rbf.xml stream\luman_uiapp_scene.ymt
