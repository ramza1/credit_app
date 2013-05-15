//= require utils
//= require jquery.tmpl.min
//= require spine/spine
//= require_self

jQuery(function($){
    window.WebPay = Spine.Controller.create({
        elements:{
            "#pay_button":"payButton",
            ".modal":"modal",
            ".modal-body":"modalBody"
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
           //if(this.payButton.hasClass("disabled")) return false;
            this.payButton.button("loading")
            var url=this.el.data('confirm-url')
            var data=this.el.serialize()
            console.log("data",data)
            $.ajax({
                type: "POST",
                url: url+".json ",
                data:data,
                error:this.proxy(function(data){
                    this.payButton.button("reset")
                }),
                success:this.proxy(function(data){
                     window.location=$(this.el).attr('action');
                })
            })
            return false;
        },
        doPay:function(){
            var url=$(this.el).attr('action');
            var data=this.el.serialize()
            $.ajax({
                type: "POST",
                url: url,
                data:data,
                error:this.failure,
                success:this.success
            })
        },
        render:function(el){

        },
        success:function(data){
            console.log(data)
            this.modalBody.html(data)
        },
        failure:function(data){
            console.log("error",data)
            //eval(data.responseText)
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


