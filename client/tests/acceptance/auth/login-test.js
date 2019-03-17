import { module, test } from 'qunit';
import { visit, currentURL, fillIn, click, find, waitFor } from '@ember/test-helpers';
import { setupApplicationTest } from 'ember-qunit';
import setupMirage from 'ember-cli-mirage/test-support/setup-mirage';
import scenarios from "mirror/mirage/scenarios";

module('Acceptance | auth/login', function(hooks) {
  setupApplicationTest(hooks);
  setupMirage(hooks);

  test('visiting /auth/login', async function(assert) {
    await visit('/auth/login');

    assert.equal(currentURL(), '/auth/login');
  });

  test('login works when valid credentials are entered', async function(assert) {
    scenarios.auth.login_success(server);

    await visit('/auth/login');
    await fillIn('#login-username', 'test')
    await fillIn('#login-password', 'password');
    await click('button[type="submit"]');
    await waitFor('.post-login');

    assert.equal(currentURL(), '/app');
  })

  test('login fails when invalid credentials are entered', async function(assert) {
    scenarios.auth.login_failure(server);

    await visit('/auth/login');
    await fillIn('#login-username', 'test')
    await fillIn('#login-password', 'password');
    await click('button[type="submit"]');

    assert.ok(find(".alert-danger"))
    assert.notEqual(currentURL(), '/app');
  });
});
