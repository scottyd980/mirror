import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | app/retrospectives/retrospective/start', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:app/retrospectives/retrospective/start');
    assert.ok(route);
  });
});
