import Component from '@ember/component';

export default Component.extend({
  actions: {
    cardImage: function (card) {
      const brand = card.get('brand');
      if (brand) {
        const lcBrand = brand.toLowerCase();
        switch (lcBrand) {
          case "american express":
            return '/img/cards/american-express.png';
          case "diner's club":
          case "diners club":
            return '/img/cards/diners-club.png';
          case "discover":
            return '/img/cards/discover.png';
          case "jcb":
            return '/img/cards/jcb.png';
          case "master card":
          case "mastercard":
            return '/img/cards/master-card.png';
          case "visa":
            return "/img/cards/visa.png";
          default:
            return "";

        }
      }
      return "";
    },
    onConfirm(message, action) {
      this.get('notifications').confirmAction(message, action);
    }
  }
});
