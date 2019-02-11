import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | app/retrospectives/retrospective/summary', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:app/retrospectives/retrospective/summary');
    assert.ok(route);
  });
});
