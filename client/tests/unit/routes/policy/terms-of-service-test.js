import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | policy/terms-of-service', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:policy/terms-of-service');
    assert.ok(route);
  });
});
