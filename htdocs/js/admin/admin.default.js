
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
    
    wb.form_build = function(data, control){
        
        data = data.replace(/&apos;/g, "'");
        //console.info('wb.form_build', data, control);
        data = JSON.parse(data);
        //console.info('wb.form_build', data, control);
        
        //console.log('body', data['body']);
        
        for(var i=0; i<control.length; i++){
            
            var c = control[i];
            var d = data[c.name];
            
            console.log('c=', c);
            console.log('d=', d);
            
        }
        
        
    };
    
})();

