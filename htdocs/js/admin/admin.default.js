
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
        
        if ( data != '' ) {
            data = data.replace(/&apos;/g, "'");
            data = JSON.parse(data);
        }
        whereto_d = $(whereto);
        
        
        
        for(var i=0; i<control.length; i++){
            
            var c = control[i];
            var d = data[c.name];
            var id = whereto_d.attr('id')+'_'+c.name;
            
            var d_value = '';
            if( d != undefined ){
                d_value = d.value;
            }
            
            if( c.type == 'hidden' ){
                var inp = $('<input type="hidden" id="'+id+'" name="'+c.name+'" value="'+d_value+'">');
                whereto_d.append(inp);
            }else if( c.type == 'edit' ){
                var wrap = $('<div class="form-group">');
                var label = $('<label for="'+id+'">');
                label.append(document.createTextNode(c.label));
                var inp = $('<input type="text" class="form-control" id="'+id+'" name="'+c.name+'" value="'+d_value+'">');
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
                if( d_value == c.value_chk ){
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
                    if( opt[0] == d_value ){
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
                var textarea = $('<textarea class="form-control" id="'+id+'" name="'+c.name+'">'+d_value+'</textarea>');
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
                var textarea = $('<textarea class="form-control" id="'+id+'" name="'+c.name+'">'+d_value+'</textarea>');
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
                if( c.empty_option ){
                    select.append($('<option value="0" >[ non selected ]</option>'));
                }
                if( 'option' in c ){
                    for(var a=0; a<c.option.length; a++){
                        var opt = c.option[a];
                        if( opt[0] == d_value ){
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
        
        whereto_d.on('submit', function(ev){
            
            event.preventDefault();
            //console.log('form submit');
            // whereto_d.attr('action')
            
            
            
            $.post(
                whereto_d.attr('action'),
                $(this).serialize()
            ).done(function( data ){
                
                console.log( "Data Loaded: " + data );
                console.log(arguments);
                
                new jBox('Notice', {
                    content: 'success!!!1',
                    color: 'blue'
                });
                
            }).fail(function( ev, str1, str2 ){
                //alert( "error" );
                //console.log(arguments);
                
                new jBox('Notice', {
                    content: str2,
                    color: 'red'
                });
                
                /*
                new jBox('Modal', {
                    width: 300,
                    height: 100,
                    title: str1,
                    content: str2
                }).open();
                */
            });
            
            //console.log( $(this).serialize() );
            
            return false;
        });
        
        
        
    };
    
    
    
    wb.make_tr = function(data, control, whereto){
        
        data = data.replace(/&apos;/g, "'");
        data = JSON.parse(data);
        whereto_d = $(whereto);
        
        var tr = $('<tr>');
        
        for(var i=0; i<control.length; i++){
            
            var c = control[i];
            var d = data[c.name];
            var id = whereto_d.attr('id')+'_'+c.name;
            
            if( c.type == 'label' ){
                tr.append($('<td>'+d.value+'</td>'));
            }else if( c.type == 'edit' ){
                
                if( 'edit_link' in c ){
                    var edit_link = c.edit_link;
                    for (var name in data){
                        edit_link = edit_link.replace(':'+name, data[name].value);
                    }
                    //console.log('edit_link2=', edit_link);
                    
                    tr.append($('<td><a href="'+edit_link+'">'+d.value+'</a></td>'));
                }else{
                    
                    tr.append($('<td>'+d.value+'</td>'));
                }
                
            }else if( c.type == 'submit' ){
                tr.append($('<td>submit</td>'));
            }else if( c.type == 'checkbox' ){
                
                var value = d.value;
                
                if( 'value_chk' in c ){
                    if( c.value_chk == d.value ){
                        value = 'yes';
                    }else{
                        value = 'no';
                    }
                }
                
                tr.append($('<td>'+value+'</td>'));
                
            }else if( c.type == 'enum' ){
                
                var value = d.value;
                
                if( 'option' in c ){
                    for(var a=0; a<c.option.length; a++){
                        var opt = c.option[a];
                        if( opt[0] == d.value ){
                            value = opt[1];
                        }
                    }
                }
                
                tr.append($('<td>'+value+'</td>'));
                
            }else if( c.type == 'text' ){
                tr.append($('<td>'+d.value+'</td>'));
            }else if( c.type == 'wysiwyg' ){
                tr.append($('<td>'+d.value+'</td>'));
            }else if( c.type == 'select' ){
                
                var value = d.value;
                
                if( 'option' in c ){
                    for(var a=0; a<c.option.length; a++){
                        var opt = c.option[a];
                        if( opt[0] == d.value ){
                            value = opt[1];
                        }
                    }
                }
                
                tr.append($('<td>'+value+'</td>'));
            }
        }
        
        whereto_d.append(tr);
    };
    
    
})();

