import Component from '@ember/component';
import { sort } from '@ember/object/computed';

export default Component.extend({
  tagName: "",
  showTeams: false,
  sortedRetros: sort('retrospectives', (retroA, retroB) => {
    const retroAId = parseInt(retroA.id),
          retroBId = parseInt(retroB.id);

    if(retroAId > retroBId) {
      return 1;
    } else if(retroBId > retroAId) {
      return -1;
    }

    return 0;
  })
});
