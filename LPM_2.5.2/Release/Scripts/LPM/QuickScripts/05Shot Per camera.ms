
		AllCameras=for cam in $cameras where superclassof cam==camera collect cam
		
		for i=1 to AllCameras.count do
		(
			TmpCam=AllCameras[i]
			if(isvalidnode TmpCam) then
			(
				theShot=LPM_Fun.createShot LPM_Root
				theShot.name="LPM_"+TmpCam.name
				theCp=LPM_Fun.firstChildByType theShot "commonProps"
				theCp.cameraTgl=true
				theCp._camera=TmpCam
				
			)
		)
		LPM_treeview_rollout.updateTV()
		
	