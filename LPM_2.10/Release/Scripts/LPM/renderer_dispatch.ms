-- The purpose of this code is to call renderer specific overrides that could be destructive to other workflows.
-- Needs LPM_RenderDispatchAction defined as #preRender or #postRender when the dispatch is called, for the subsequent scripts to work

curRenderer = ( renderers.current as string )

case curRenderer of
(
    default                                                 : () --print"default"
    "Default_Scanline_Renderer:Default_Scanline_Renderer"   : () --print "Scanline"
    "V_Ray_5__update_1:V_Ray_5__update_1"                   : ( filein ( LPM_Dir+"renderer_vray5.ms" ) )
    "V_Ray_5__update_1_3:V_Ray_5__update_1_3"               : ( filein ( LPM_Dir+"renderer_vray5.1.3.ms" ) )
    "V_Ray_GPU_5__update_1:V_Ray_GPU_5__update_1"           : ( print "Vray5 GPU not currently supported" )
    "V_Ray_6__update_2:V_Ray_6__update_2"                   : ( filein ( LPM_Dir+"renderer_vray6.20.02.ms" ) )
    "V_Ray_7_Beta:V_Ray_7_Beta"                             : ( filein ( LPM_Dir+"renderer_vray7beta.ms" ) )
    "V_Ray_7_Hotfix_1:V_Ray_7_Hotfix_1"                     : ( filein ( LPM_Dir+"renderer_vray7.00.04.ms" ) )
)


