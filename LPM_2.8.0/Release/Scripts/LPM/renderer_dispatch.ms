-- The purpose of this code is to call renderer specific overrides that could be destructive to other workflows.
-- Needs LPM_RenderDispatchAction defined as #preRender or #postRender when the dispatch is called, for the subsequent scripts to work

curRenderer = ( renderers.current as string )

case curRenderer of
(
    default                                                 : () --print"default"
    "Default_Scanline_Renderer:Default_Scanline_Renderer"   : () --print "Scanline"
    "V_Ray_5__update_1:V_Ray_5__update_1"                   : ( filein (LPM_Dir+"renderer_vray5.ms") )
    "V_Ray_GPU_5__update_1:V_Ray_GPU_5__update_1"           : ( filein (LPM_Dir+"renderer_vray5.ms") )
)
