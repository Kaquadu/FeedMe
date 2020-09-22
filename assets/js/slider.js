const Slider = {
  INDEX: 0,

  run() {
    this.initialize($('.custom-slider'))
  },

  initialize(jquery_item) {
    var slides = jquery_item.children('.slide')
    var dots = jquery_item.children('.slider-dots-row').children('.slider-dot')

    var self = this;

    this.hide_slides(slides, dots);
    this.show_slide(self, 0, slides, dots);

    this.slideshow(self, slides, dots);

    // for (var i = 0; i < dots.length; i++) {
    //   dots[i].addEventListener('click', (event) => {
    //     self.hide_slides(slides, dots);
    //     self.show_slide(self, event.target.dataset.trigger, slides, dots)
    //   })
    // }
  },

  slideshow(self, slides, dots) {

    if (self.INDEX < (slides.length-1)) {
      self.hide_slides(slides, dots);
      self.show_slide(self, self.INDEX+1, slides, dots);
    } else {
      self.hide_slides(slides, dots);
      self.show_slide(self, 0, slides, dots);
    }

    setTimeout(self.slideshow, 8000, self, slides, dots)
  },

  hide_slides(slides, dots) {
    for (var i = 0; i < slides.length; i++) {
      slides[i].style.display = "none";
    }

    for (var i = 0; i < dots.length; i++) {
      dots[i].className = 'slider-dot'
    }
  },

  show_slide(self, i, slides, dots) {
    self.INDEX = i;
    slides[i].style.display = "block";
    dots[i].className = 'slider-dot-active'
  }
}

export default Slider;
