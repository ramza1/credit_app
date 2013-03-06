# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  Morris.Line
    element: 'transactions_chart'
    data: $('#transactions_chart').data('transactions')
    xkey: 'completed_at'
    ykeys: ['transactions']
    labels: ['Total Transaction']
