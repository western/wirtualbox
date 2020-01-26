
// site.default.js

if( typeof(wb) == "undefined" )
(function(){
	
	var wb = window.wb = {};
	
	wb.rnd = new Date().getTime();
	wb.rnd_min = function(){
		var dt = new Date();
		
		var year = dt.getFullYear();
		var month = dt.getMonth(); month ++;
		var day = dt.getDate();
		
		var hour = dt.getHours();
		var minute = dt.getMinutes();
		
		return year+'-'+month+'-'+day+'-'+hour+'-'+minute;
	};
    
})();

