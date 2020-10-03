const Footer = {
  run() {
    this.handleToggles();
  },

  handleToggles() {
    $("#toggle-address-button").click(() => {
      $("#toggle-address").toggle("fast", () => {})
    })
    $("#toggle-invoice-button").click(() => {
      $("#toggle-invoice").toggle("fast", () => {})
    })
  }
}

export default Footer;
