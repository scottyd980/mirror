import Ember from 'ember';

export default Ember.Component.extend({
    tagName: "ul",
    classNames: ["table-list"],
    showTeams: false,
    sortedRetros: Ember.computed.sort('retrospectives', function(a, b){
        let id1 = parseInt(a.id),
            id2 = parseInt(b.id);

        if (id1 < id2) {
            return 1;
        } else if (id1 > id2) {
            return -1;
        }

        return 0;
    })
});
