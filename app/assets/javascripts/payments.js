//= require utils
//= require jquery.tmpl.min
//= require spine/spine
//= require_self

jQuery(function($){
    window.WebPay = Spine.Controller.create({
        elements:{
            "#pay_button":"payButton",
            ".modal":"modal"
        },
        events:{
            "click .ui-btn":"click" ,
            "click .cancel":"cancel" ,
            "keyup #branch_name": "checkAvailability"
        },
        proxied: ["render",'activate','deActivate','success','failure','pay'],
        template:function(data){
        },
        init: function(){
          console.log("inited payment",this.el[0])
          this.el.bind("submit",this.pay)
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
           // if(this.payButton.hasClass("disabled")) return false;
           // this.payButton.addClass("disabled")
            //this.modal.modal('show');
            //return false;
        },
        doPay:function(){
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
    WebPay.init({
        el:$("#web_pay")
    })
})


