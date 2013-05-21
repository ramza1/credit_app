//= require utils
//= require jquery.tmpl.min
//= require spine/spine
//= require_self
jQuery(function($){
    window.WebPay = Spine.Controller.create({
        elements:{
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
        pay:function(){
            this.el.submit();
        }
    });
})

jQuery(function($){
    window.Payment = Spine.Controller.create({
        elements:{
            "#payment_selection":"payView",
            "#web_pay":"webPayForm",
            "#pay_button":"payButton"
        },
        events:{
            "click #pay_button":"click"
        },
        proxied: [],
        template:function(data){
        },
        init: function(){
            this.show()
        } ,
        click:function(ev){
            if(this.payButton.hasClass("disabled")) return false;

            this.payButton.button("loading")
            var url=this.payButton.data('confirm-url')
            var data=this.webPayForm.serialize()
            $.ajax({
                type: "POST",
                url: url+".json ",
                data:data,
                error:this.proxy(function(data){
                    this.payButton.button("reset")
                }),
                success:this.proxy(function(data){
                    this.webPay.pay()
                })
            })
            return false;
        },
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


