import { later } from '@ember/runloop';
import ENV from 'mirror/config/environment';
import RetrospectiveController from 'mirror/controllers/demo/extends/retrospective';

export default RetrospectiveController.extend({
  showModal: false,

  begin_joining: function() {
    this.start_tour();
    later(this, function() {
      this.get('model.retrospective.participants').pushObject(ENV.DEMO.team_members[3]);
      later(this, function() {
        this.get('model.retrospective.participants').pushObject(ENV.DEMO.team_members[2]);
      }, 1100);
    }, 1500);
  },

  start_tour() {
    const tour = this.get('tour');
    tour.addSteps([
      {
        id: 'tour-join',
        options: {
          attachTo: {
            element: '#tour-join',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "The Waiting Room",
          text: [
            "In the waiting room, you'll see a status indicator next to each person so you know who's here and who you're waiting on.",
            "For demo purposes, Bobby Tables can't make it, but we can still continue a retrospective even in the absence of some team members."
          ]
        }
      },
      {
        id: 'tour-moderator',
        options: {
          attachTo: {
            element: '#tour-moderator',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Moderating A Retrospective",
          text: [
            "In the demo, you're the retrospective moderator! The moderator is provided with a timer to help keep discussions under control.",
            "Others will not see the moderator actions like you do, however; they will still see everything else going on, in real-time.",
            "As you navigate through the retrospective, each member of the team will also be navigated to the correct page, too. This lets everyone stay on the same page about what is being discussed."
          ]
        }
      },
      {
        id: 'tour-cancel',
        options: {
          attachTo: {
            element: '#tour-cancel',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Next',
              type: 'next'
            }
          ],
          title: "Canceling The Retrospective",
          text: [
            "If the retrospective was created by mistake, the moderator can cancel the retrospective. The moderator can do this at any point during the retrospective.",
            "In a real retrospective, this will return all members of the team back to the team dashboard."
          ]
        }
      },
      {
        id: 'tour-continue',
        options: {
          attachTo: {
            element: '#tour-continue',
            on: 'bottom'
          },
          buttons: [
            {
              classes: 'btn btn-default shepherd-button-secondary',
              text: 'Exit',
              type: 'cancel'
            },
            {
              classes: 'btn btn-info',
              text: 'Back',
              type: 'back'
            },
            {
              classes: 'btn btn-info',
              text: 'Close',
              type: 'cancel'
            }
          ],
          title: "Continuing The Retrospective",
          text: [
            "Since you are the moderator, once everyone is ready, you can continue on!"
          ]
        }
      }
    ]);
    tour.start();
  },

  actions: {
    close: function() {
      this.set('showModal', false);
    },
    start: function() {
      this.begin_joining();
      this.send('close');
    }
  }
});
