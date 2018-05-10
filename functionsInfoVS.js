
linked=app.linked;

if ("onDemandVideos.v1" in linked) {
	ondemand = linked["onDemandVideos.v1"];
	for(var i=0; i<ondemand.length; i++) {
		var ondei = ondemand[i];
		if ("sources" in ondei) {
			var resol = ondei.sources.byResolution;
			if ("720p" in resol) {
				if ("mp4VideoUrl" in resol["720p"]) 
					console.log(resol["720p"].mp4VideoUrl);
				else if ( "webMVideoUrl" in resol["720p"])
					console.log(resol["720p"].webMVideoUrl);
			} else if ( "540p" in resol) {
				if ("mp4VideoUrl" in resol['540p']) 
					console.log(resol['540p'].mp4VideoUrl);
				else if ( "webMVideoUrl" in resol['540p']) 
					console.log(resol['540p'].webMVideoUrl);
			} else if ( "360p" in resol) {
				if ("mp4VideoUrl" in resol['360p']) 
					console.log(resol['360p'].mp4VideoUrl);
				else if ( "webMVideoUrl" in resol["360p"]) 
					console.log(resol["360p"].webMVideoUrl);
			}
		}
		if("subtitlesTxt" in ondei)
			console.log("https://www.coursera.org" + ondei.subtitlesTxt['es']);
		else if ("subtitles" in ondei)
			console.log("https://www.coursera.org" + ondei.subtitles['es']);
	}
}

phantom.exit();


