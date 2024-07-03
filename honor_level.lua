-- Ref: https://discord.com/channels/192358910387159041/643437814104457217/1242598171012628551
local RPGStatusIcons = DatabindingAddDataContainerFromPath("", "RPGStatusIcons")
local honorIcon = DatabindingAddDataContainer(RPGStatusIcons, "HonorIcon")
DatabindingAddDataInt(honorIcon, "State", 3) -- 1:lowest honor, 16:highest honor


--[[ honor_display.ymt

<?xml version="1.0" encoding="UTF-8"?>
<UIPanel>
 <Name>PAN_HonorDisplay</Name>
 <UseLayoutEngine value="True" />
 <LayoutParams type="LayoutParams">
  <params type="params">
   <horizontalAlignment>HALIGN_LEFT</horizontalAlignment>
   <verticalAlignment>VALIGN_BOTTOM</verticalAlignment>
   <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
   <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
   <width value="756" />
   <height value="54" />
  </params>
 </LayoutParams>
 <BehaviorSet type="BehaviorSet">
  <Behaviors>
   <Item>
    <SlotType>HUD_VISIBILITY_SLOT_HONOR</SlotType>
    <DefaultToVisible value="False" />
   </Item>
   <Item>
    <SymbolName>fcContainer</SymbolName>
   </Item>
  </Behaviors>
 </BehaviorSet>
 <Children>
  <Item>
   <Name>IMG_Background</Name>
   <TextureDictionary>honor_display</TextureDictionary>
   <Texture>HONOR_BG</Texture>
   <Color>COLOR_BLACK</Color>
   <UseLayoutEngine value="True" />
   <LayoutParams type="LayoutParams">
    <params type="params">
     <horizontalAlignment>HALIGN_STRETCH</horizontalAlignment>
     <verticalAlignment>VALIGN_STRETCH</verticalAlignment>
     <widthContentMode>CONTENT_MODE_AUTO</widthContentMode>
     <heightContentMode>CONTENT_MODE_AUTO</heightContentMode>
    </params>
   </LayoutParams>
   <SpecializedLayoutParams>
    <Item>
     <params type="params">
      <Stretch>UNIFORM</Stretch>
     </params>
    </Item>
   </SpecializedLayoutParams>
  </Item>
  <Item>
   <Name>PAN_BarWithIcon</Name>
   <UseLayoutEngine value="True" />
   <LayoutParams type="LayoutParams">
    <params type="params">
     <horizontalAlignment>HALIGN_CENTER</horizontalAlignment>
     <verticalAlignment>VALIGN_CENTER</verticalAlignment>
     <widthContentMode>CONTENT_MODE_AUTO</widthContentMode>
     <heightContentMode>CONTENT_MODE_AUTO</heightContentMode>
    </params>
   </LayoutParams>
   <Children>
    <Item>
     <Name>REC_BarBackground</Name>
     <Color>COLOR_HONOR_7</Color>
     <Alpha value="80" />
     <UseLayoutEngine value="True" />
     <LayoutParams type="LayoutParams">
      <params type="params">
       <horizontalAlignment>HALIGN_STRETCH</horizontalAlignment>
       <verticalAlignment>VALIGN_STRETCH</verticalAlignment>
       <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
       <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
       <width value="648" />
       <height value="11" />
      </params>
     </LayoutParams>
    </Item>
    <Item>
     <Name>STACK_Bar</Name>
     <UseLayoutEngine value="True" />
     <LayoutParams type="LayoutParams">
      <params type="params">
       <horizontalAlignment>HALIGN_CENTER</horizontalAlignment>
       <verticalAlignment>VALIGN_CENTER</verticalAlignment>
       <widthContentMode>CONTENT_MODE_AUTO</widthContentMode>
       <heightContentMode>CONTENT_MODE_AUTO</heightContentMode>
      </params>
     </LayoutParams>
     <SpecializedLayoutParams>
      <Item>
       <params type="params">
        <orientation>PANEL_ORIENT_HORIZONTAL</orientation>
       </params>
      </Item>
     </SpecializedLayoutParams>
     <BehaviorSet type="BehaviorSet">
      <Behaviors>
       <Item>
        <SymbolName>fcContainer</SymbolName>
       </Item>
      </Behaviors>
     </BehaviorSet>
     <Children>
      <Item>
       <Name>IMG_BarLeft</Name>
       <TextureDictionary>honor_display</TextureDictionary>
       <Texture>HONOR_BAR_GRAD_HALF</Texture>
       <Color>COLOR_HONOR_0</Color>
       <FlipHorizontal value="True" />
       <FlipVertical value="True" />
       <UseLayoutEngine value="True" />
       <LayoutParams type="LayoutParams">
        <params type="params">
         <horizontalAlignment>HALIGN_LEFT</horizontalAlignment>
         <verticalAlignment>VALIGN_TOP</verticalAlignment>
         <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
         <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
         <width value="328" />
         <height value="12" />
        </params>
       </LayoutParams>
       <SpecializedLayoutParams>
        <Item>
         <params type="params">
          <Stretch>NONE</Stretch>
         </params>
        </Item>
       </SpecializedLayoutParams>
      </Item>
      <Item>
       <Name>IMG_BarRight</Name>
       <TextureDictionary>honor_display</TextureDictionary>
       <Texture>HONOR_BAR_GRAD_HALF</Texture>
       <UseLayoutEngine value="True" />
       <LayoutParams type="LayoutParams">
        <params type="params">
         <horizontalAlignment>HALIGN_RIGHT</horizontalAlignment>
         <verticalAlignment>VALIGN_TOP</verticalAlignment>
         <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
         <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
         <width value="328" />
         <height value="12" />
        </params>
       </LayoutParams>
       <SpecializedLayoutParams>
        <Item>
         <params type="params">
          <Stretch>NONE</Stretch>
         </params>
        </Item>
       </SpecializedLayoutParams>
      </Item>
     </Children>
    </Item>
    <Item>
     <Name>PAN_Icon</Name>
     <UseLayoutEngine value="True" />
     <LayoutParams type="LayoutParams">
      <params type="params">
       <horizontalAlignment>HALIGN_LEFT</horizontalAlignment>
       <verticalAlignment>VALIGN_CENTER</verticalAlignment>
       <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
       <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
       <height value="40" />
       <width value="40" />
      </params>
     </LayoutParams>
     <BehaviorSet type="BehaviorSet">
      <Behaviors>
       <Item>
        <SymbolName>fcContainer</SymbolName>
       </Item>
       <Item>
        <Name>honor_anim</Name>
        <Animation>honor_display_linear</Animation>
        <BindingSetup type="BindingSetup">
         <Path>ScriptDatastoreRoot.RPGStatusIcons.HonorIcon.State</Path>
         <PathType>PATH_ABSOLUTE</PathType>
        </BindingSetup>
        <ScaleObjectContext type="ScaleObjectContext">
         <Path>^</Path>
         <PathType>PATH_LOCAL</PathType>
        </ScaleObjectContext>
        <Converter type="Converter">
         <ApplyDefault value="True" />
         <Default x="0.5" y="0" />
         <Dictionary>
          <Item key="1" x="0" y="0" />
          <Item key="2" x="0.0625" y="0" />
          <Item key="3" x="0.125" y="0" />
          <Item key="4" x="0.1875" y="0" />
          <Item key="5" x="0.25" y="0" />
          <Item key="6" x="0.3125" y="0" />
          <Item key="7" x="0.375" y="0" />
          <Item key="8" x="0.4375" y="0" />
          <Item key="9" x="0.5" y="0" />
          <Item key="10" x="0.5625" y="0" />
          <Item key="11" x="0.625" y="0" />
          <Item key="12" x="0.6875" y="0" />
          <Item key="13" x="0.75" y="0" />
          <Item key="14" x="0.8125" y="0" />
          <Item key="15" x="0.875" y="0" />
          <Item key="16" x="0.9375" y="0" />
         </Dictionary>
        </Converter>
       </Item>
      </Behaviors>
     </BehaviorSet>
     <Children>
      <Item>
       <Name>IMG_Background</Name>
       <Style>HUD_BG</Style>
       <TextureDictionary>honor_display</TextureDictionary>
       <Texture>HONOR_BACKGROUND</Texture>
       <UseLayoutEngine value="True" />
       <LayoutParams type="LayoutParams">
        <params type="params">
         <horizontalAlignment>HALIGN_CENTER</horizontalAlignment>
         <verticalAlignment>VALIGN_CENTER</verticalAlignment>
         <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
         <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
         <height value="40" />
         <width value="40" />
        </params>
       </LayoutParams>
       <SpecializedLayoutParams>
        <Item>
         <params type="params">
          <Stretch>NONE</Stretch>
         </params>
        </Item>
       </SpecializedLayoutParams>
       <BehaviorSet type="BehaviorSet">
        <Behaviors>
         <Item />
        </Behaviors>
       </BehaviorSet>
      </Item>
      <Item>
       <Name>IMG_IconGraphic</Name>
       <TextureDictionary>honor_display</TextureDictionary>
       <Texture>HONOR_GOOD</Texture>
       <Color>COLOR_WHITE</Color>
       <UseLayoutEngine value="True" />
       <LayoutParams type="LayoutParams">
        <params type="params">
         <horizontalAlignment>HALIGN_CENTER</horizontalAlignment>
         <verticalAlignment>VALIGN_CENTER</verticalAlignment>
         <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
         <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
         <height value="40" />
         <width value="40" />
        </params>
       </LayoutParams>
       <BehaviorSet type="BehaviorSet">
        <Behaviors>
         <Item />
        </Behaviors>
       </BehaviorSet>
       <SpecializedLayoutParams>
        <Item>
         <params type="params">
          <Stretch>NONE</Stretch>
         </params>
        </Item>
       </SpecializedLayoutParams>
       <MemberBindings>
        <Item>
         <MemberName>Texture</MemberName>
         <Setup type="Setup">
          <Path>ScriptDatastoreRoot.RPGStatusIcons.HonorIcon.State</Path>
          <PathType>PATH_ABSOLUTE</PathType>
         </Setup>
         <Converter type="Converter">
          <ApplyDefault value="True" />
          <Default>HONOR_GOOD</Default>
          <Dictionary>
           <Item key="1">
            <>HONOR_BAD</>
           </Item>
           <Item key="2">
            <>HONOR_BAD</>
           </Item>
           <Item key="3">
            <>HONOR_BAD</>
           </Item>
           <Item key="4">
            <>HONOR_BAD</>
           </Item>
           <Item key="5">
            <>HONOR_BAD</>
           </Item>
           <Item key="6">
            <>HONOR_BAD</>
           </Item>
           <Item key="7">
            <>HONOR_BAD</>
           </Item>
           <Item key="8">
            <>HONOR_BAD</>
           </Item>
           <Item key="9">
            <>HONOR_GOOD</>
           </Item>
           <Item key="10">
            <>HONOR_GOOD</>
           </Item>
           <Item key="11">
            <>HONOR_GOOD</>
           </Item>
           <Item key="12">
            <>HONOR_GOOD</>
           </Item>
           <Item key="13">
            <>HONOR_GOOD</>
           </Item>
           <Item key="14">
            <>HONOR_GOOD</>
           </Item>
           <Item key="15">
            <>HONOR_GOOD</>
           </Item>
           <Item key="16">
            <>HONOR_GOOD</>
           </Item>
          </Dictionary>
         </Converter>
        </Item>
        <Item>
         <MemberName>Color</MemberName>
         <Setup type="Setup">
          <Path>ScriptDatastoreRoot.RPGStatusIcons.HonorIcon.State</Path>
          <PathType>PATH_ABSOLUTE</PathType>
         </Setup>
         <Converter type="Converter">
          <ApplyDefault value="True" />
          <Default>COLOR_HONOR_8</Default>
          <Dictionary>
           <Item key="1">
            <>COLOR_HONOR_0</>
           </Item>
           <Item key="2">
            <>COLOR_HONOR_1</>
           </Item>
           <Item key="3">
            <>COLOR_HONOR_2</>
           </Item>
           <Item key="4">
            <>COLOR_HONOR_3</>
           </Item>
           <Item key="5">
            <>COLOR_HONOR_4</>
           </Item>
           <Item key="6">
            <>COLOR_HONOR_5</>
           </Item>
           <Item key="7">
            <>COLOR_HONOR_6</>
           </Item>
           <Item key="8">
            <>COLOR_HONOR_7</>
           </Item>
           <Item key="9">
            <>COLOR_HONOR_8</>
           </Item>
           <Item key="10">
            <>COLOR_HONOR_9</>
           </Item>
           <Item key="11">
            <>COLOR_HONOR_10</>
           </Item>
           <Item key="12">
            <>COLOR_HONOR_11</>
           </Item>
           <Item key="13">
            <>COLOR_HONOR_12</>
           </Item>
           <Item key="14">
            <>COLOR_HONOR_13</>
           </Item>
           <Item key="15">
            <>COLOR_HONOR_14</>
           </Item>
           <Item key="16">
            <>COLOR_HONOR_15</>
           </Item>
          </Dictionary>
         </Converter>
        </Item>
       </MemberBindings>
      </Item>
      <Item>
       <Name>IMG_Flash</Name>
       <Color>COLOR_WHITE</Color>
       <TextureDictionary>honor_display</TextureDictionary>
       <Texture>HONOR_BACKGROUND</Texture>
       <UseLayoutEngine value="True" />
       <LayoutParams type="LayoutParams">
        <params type="params">
         <horizontalAlignment>HALIGN_CENTER</horizontalAlignment>
         <verticalAlignment>VALIGN_CENTER</verticalAlignment>
         <widthContentMode>CONTENT_MODE_RAW</widthContentMode>
         <heightContentMode>CONTENT_MODE_RAW</heightContentMode>
         <height value="40" />
         <width value="40" />
        </params>
       </LayoutParams>
       <SpecializedLayoutParams>
        <Item>
         <params type="params">
          <Stretch>FILL</Stretch>
         </params>
        </Item>
       </SpecializedLayoutParams>
       <BehaviorSet type="BehaviorSet">
        <Behaviors>
         <Item>
          <YPadding value="10" />
          <XPadding value="10" />
          <VerticalPivot>CENTER</VerticalPivot>
          <HorizontalPivot>CENTER</HorizontalPivot>
         </Item>
        </Behaviors>
       </BehaviorSet>
      </Item>
     </Children>
    </Item>
   </Children>
  </Item>
 </Children>
</UIPanel>
]]
