import Component from '@ember/component';

export default Component.extend({
  classNames: ['note'],
  classNameBindings: ['type'],
  isModerator: null,
  isAnonymous: null,
  type: '',
});
