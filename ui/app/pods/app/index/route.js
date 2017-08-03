import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../config/environment';

const { inject } = Ember;

export default Ember.Route.extend({
    session: inject.service(),
    model() {
        let current_user = this.get('session.currentUser');

        return RSVP.hash({
            teams: current_user.get('teams').sortBy('id'),
            organizations: current_user.get('organizations').sortBy('id'),
            recent_retrospectives: current_user.get('teams').then((teams) => {
                let retros = teams.map((team) => {
                    return this.store.query('retrospective', {
                        filter: {
                            team: team.get('id')
                        }
                    })
                })

                return RSVP.allSettled(retros).then((retrospectives) => {
                    let retro_list = retrospectives.reduce((retro_arr, retrospective) => {
                        return retro_arr.concat(retrospective.value.toArray());
                    }, []);

                    // TODO: Need to order by date and then take the most recent ones.
                    
                    return retro_list;
                });
                
                // teams.forEach((team) => {
                //     this.store.query('retrospective', {
                //         filter: {
                //             team: team.get('id')
                //         }
                //     }).then((retrospectives) => {
                //         retrospectives.forEach((retrospective) => {
                //             recent_retros.push(retrospective);
                //         });
                //     }).then(() => {
                //         return recent_retros;
                //     });
                // });
            })
        });
    },
    setupController(controller, model) {
        this._super(controller, model);
        console.log(model.recent_retrospectives);
    }
});
