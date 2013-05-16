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
            "click #pay_button":"click"
        },
        proxied: ["render"],
        template:function(data){
        },
        init: function(){
          //console.log("inited payment",this.el[0])
          //this.el.bind("submit",this.pay)
        } ,
        show:function(){
        },
        activate:function(){
            this.el.modal();
        },
        deActivate:function(){
            this.el.modal('hide');
        },
        click:function(ev){
           //if(this.payButton.hasClass("disabled")) return false;
            /**
            this.payButton.button("loading")
            var url=this.el.data('confirm-url')
            var data=this.el.serialize()
            $.ajax({
                type: "POST",
                url: url+".json ",
                data:data,
                error:this.proxy(function(data){
                    this.payButton.button("reset")
                }),
                success:this.proxy(function(data){
                     this.el.submit()
                })
            })
            return false;  **/
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
})

jQuery(function($){
    window.Payment = Spine.Controller.create({
        elements:{
            "#payment_selection":"payView",
            "#web_pay":"webPayForm"
        },
        events:{
        },
        proxied: [],
        template:function(data){
        },
        init: function(){
            this.show()
        } ,
        show:function(){
            this.webPay=WebPay.init({
                el:this.webPayForm
            })
            this.payView.show()
        }
    });
    Payment.init({
        el:$("body")
    })
})


