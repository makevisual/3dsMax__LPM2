rollout vrayRenderElementsPropsRoll "VRay Render Elements Override 1.0" width:325 height:390
(
    local theNode = undefined

    groupbox grp_RenderElements "Select Render Elements" width:313 height:378 slign:#left offset:[-5,0] enabled:true--false
    dotNetControl elementList "system.windows.forms.listView" width:293 height:350 offset:[5, ( ( grp_RenderElements.height * -1 ) + 14 ) ] --pos:[4,248]

 
    on vrayRenderElementsPropsRoll open do
    (

    )    
)
createDialog vrayRenderElementsPropsRoll pos:(LPM_Fun.getRoPos  vrayRenderElementsPropsRoll.width)