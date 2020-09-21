const Header = {

  run() {
    this.handleHeader();
    this.handleResponsiveness();
  },

  handleHeader() {
    var header = document.getElementById('sticky-navbar');
    var sticky = header.offsetTop;

    if (header == null) {return;}

    document.addEventListener('scroll', () => {
      if (window.pageYOffset > sticky) {
        header.classList.add("sticky");
      } else {
        header.classList.remove("sticky");
      }
    })
  },

  handleResponsiveness() {
    var x = $('#sticky-navbar')

    $('#header-icon').click(() => {
      if (x.hasClass('responsive')) {
        x.removeClass('responsive')
      } else {
        x.addClass('responsive')
      }
    })
  }
}

export default Header;
