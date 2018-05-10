
objstores=app.context.dispatcher.stores;
objcourse=objstores.CourseStore;

objrawmaterial=objcourse.rawCourseMaterials

objcoursedata=objrawmaterial.courseData;
objmaterial=objrawmaterial.courseMaterialsData;

objschedule=objstores.CourseScheduleStore.rawSchedule;

getweeknum = function(sch, id) {
	var nweek = 1;
	for(var i=0;i<sch.length;i++) {
		schi = sch[i];
		modules = schi.moduleIds;
		numweek = Number(schi.numberOfWeeks);
		var sweek = "";
		var lweek = "";
		for(var j=0;j<numweek;j++) {
			sweek = sweek + lweek + nweek.toString();
			lweek = "-";
			nweek++;
		}
		for(var j=0;j<modules.length;j++) {
			idm = modules[j];
			if (idm == id) 
				return sweek;
		}
	}
	return "?";
}

re = function(obj, infoweek, flag) {
	for(var i=0;i<obj.length;i++) {
		var obji = obj[i];
		if (flag)
			if ("id" in obji)
				infoweek = getweeknum(objschedule, obji.id);
			else
				continue;

		if("elements" in obji) {
			re(obji.elements, infoweek, false);
		} else {
			if ("contentSummary" in obji && "definition" in obji.contentSummary && "duration" in obji.contentSummary.definition)
				console.log(infoweek + " " + obji.id + " [[" + objcoursedata.name + "]] " + obji.name);
		}
	}
}
console.log(objstores.CourseStore.courseId);

if ("elements" in objmaterial) {
	re(objmaterial.elements, "1", true);
}
else {
	//console.log("There is not any element parameters in the object");
}
phantom.exit();
