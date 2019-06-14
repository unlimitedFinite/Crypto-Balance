//= require rails-ujs
//= require_tree .

if($('.alert').hasClass('show')) {
  setTimeout(() => {
    $('.alert').fadeOut();
  }, 6000)
}
