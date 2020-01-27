
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
    wb.capitalize_first = function(n){
        return n.charAt(0).toUpperCase() + n.slice(1);
    };
    
    wb.form_build = function(data, control, whereto){
        
        data = data.replace(/&apos;/g, "'");
        data = JSON.parse(data);
        whereto_d = $(whereto);
        
        
        
        for(var i=0; i<control.length; i++){
            
            var c = control[i];
            var d = data[c.name];
            var id = whereto_d.attr('id')+'_'+c.name;
            
            
            
            if( c.type == 'hidden' ){
                var inp = $('<input type="hidden" id="'+id+'" name="'+c.name+'" value="'+d.value+'">');
                whereto_d.append(inp);
            }else if( c.type == 'edit' ){
                var wrap = $('<div class="form-group">');
                var label = $('<label for="'+id+'">');
                label.append(document.createTextNode(c.label));
                var inp = $('<input type="text" class="form-control" id="'+id+'" name="'+c.name+'" value="'+d.value+'">');
                wrap.append(label);
                wrap.append(inp);
                if( 'note' in c ){
                    wrap.append($('<small class="form-text text-muted">'+c.note+'</small>'));
                }
                whereto_d.append(wrap);
            }else if( c.type == 'submit' ){
                var wrap = $('<div class="form-group float-right">');
                var inp = $('<button type="submit" class="btn btn-primary" id="'+id+'" name="'+c.name+'" value="1">'+c.label+'</button>');
                wrap.append(inp);
                whereto_d.append(wrap);
            }else if( c.type == 'checkbox' ){
                var wrap = $('<div class="form-group form-check">');
                var label = $('<label class="form-check-label" for="'+id+'">');
                label.append(document.createTextNode(c.label));
                var inp = $('<input type="checkbox" class="form-check-input" id="'+id+'" name="'+c.name+'" value="'+c.value_chk+'">');
                if( d.value == c.value_chk ){
                    inp.attr('checked', 'checked');
                }
                wrap.append(inp);
                wrap.append(label);
                if( 'note' in c ){
                    wrap.append($('<small class="form-text text-muted">'+c.note+'</small>'));
                }
                whereto_d.append(wrap);
            }else if( c.type == 'enum' ){
                var wrap = $('<div class="form-group">');
                var label = $('<label for="'+id+'">');
                label.append(document.createTextNode(c.label));
                var select = $('<select class="form-control" id="'+id+'" name="'+c.name+'" >');
                for(var a=0; a<c.option.length; a++){
                    var opt = c.option[a];
                    if( opt[0] == d.value ){
                        select.append($('<option value="'+opt[0]+'" selected="selected" >'+opt[1]+'</option>'));
                    }else{
                        select.append($('<option value="'+opt[0]+'" >'+opt[1]+'</option>'));
                    }
                }
                wrap.append(label);
                wrap.append(select);
                if( 'note' in c ){
                    wrap.append($('<small class="form-text text-muted">'+c.note+'</small>'));
                }
                whereto_d.append(wrap);
            }else if( c.type == 'text' ){
                var wrap = $('<div class="form-group">');
                var label = $('<label for="'+id+'">');
                label.append(document.createTextNode(c.label));
                var textarea = $('<textarea class="form-control" id="'+id+'" name="'+c.name+'">'+d.value+'</textarea>');
                wrap.append(label);
                wrap.append(textarea);
                if( 'note' in c ){
                    wrap.append($('<small class="form-text text-muted">'+c.note+'</small>'));
                }
                whereto_d.append(wrap);
            }else if( c.type == 'wysiwyg' ){
                var wrap = $('<div class="form-group">');
                var label = $('<label for="'+id+'">');
                label.append(document.createTextNode(c.label));
                var textarea = $('<textarea class="form-control" id="'+id+'" name="'+c.name+'">'+d.value+'</textarea>');
                wrap.append(label);
                wrap.append(textarea);
                if( 'note' in c ){
                    wrap.append($('<small class="form-text text-muted">'+c.note+'</small>'));
                }
                whereto_d.append(wrap);
            }else if( c.type == 'select' ){
                var wrap = $('<div class="form-group">');
                var label = $('<label for="'+id+'">');
                label.append(document.createTextNode(c.label));
                var select = $('<select class="form-control" id="'+id+'" name="'+c.name+'" >');
                if( 'option' in c ){
                    for(var a=0; a<c.option.length; a++){
                        var opt = c.option[a];
                        if( opt[0] == d.value ){
                            select.append($('<option value="'+opt[0]+'" selected="selected" >'+opt[1]+'</option>'));
                        }else{
                            select.append($('<option value="'+opt[0]+'" >'+opt[1]+'</option>'));
                        }
                    }
                }
                wrap.append(label);
                wrap.append(select);
                if( 'note' in c ){
                    wrap.append($('<small class="form-text text-muted">'+c.note+'</small>'));
                }
                whereto_d.append(wrap);
            }
        }
        
        
    };
    
})();

