//= require utils
//= require jquery.tmpl.min
//= require spine/spine
//= require_self

jQuery(function($){
    window.WebPay = Spine.Controller.create({
        elements:{
        },
        events:{
            "submit #new_branch_form" :"create",
            "click .ui-btn":"click" ,
            "click .cancel":"cancel" ,
            "keyup #branch_name": "checkAvailability"
        },
        proxied: ["render",'activate','deActivate','success','failure'],
        template:function(data){
        },
        init: function(){

        } ,
        show:function(){
            console.log("show tip branch",this.newBranchForm)
        },
        activate:function(){
            this.el.modal();
        },
        deActivate:function(){
            this.el.modal('hide');
        },
        pay:function(ev){
            if(this.createButton.hasClass("disabled")) return false;
            url=$(ev.target).attr('action');

            console.log("target",$(ev))
            console.log("submit",url)
            data=$(ev.target).serialize()
            $.ajax({
                type: "POST",
                url: url+".js",
                data:data,
                error:this.failure,
                success:this.success
            })

            this.createButton.button('loading')
            return false;
        },
        render:function(el){

        },
        success:function(data){
            //console.log(data)
            this.el.modal('hide');
            this.createButton.addClass("disabled")
            this.createButton.button('complete')
            this.hideHint();
            this.nameEl.find('.control-group').removeClass("success error warning")
        },
        failure:function(data){
            console.log("error",data.responseText)
            //eval(data.responseText)
            this.createButton.button('complete')
            this.createButton.addClass("disabled")
            this.nameEl.find('.control-group').addClass("error")
            //this.showHint('<i class="icon-warning"></i> '+data.name);
        },
        cancel:function(){
            if(this.xhr && this.xhr.readystate!=4){
                this.xhr.abort()
            }
            this.createButton.button('complete')
            this.el.modal('hide');
            this.hideHint();
            return false
        }
    });
})

jQuery(function($){
    window.Payment = Spine.Controller.create({
        elements:{
            "#web_pay":"webPayForm"
        },
        events:{},
        proxied: ["render",'activate','deActivate','success','failure'],
        template:function(data){

        },
        init: function(){
        } ,
        show:function(){
        }

    });
    Payment.init({
        el:$("#")
    })
})
