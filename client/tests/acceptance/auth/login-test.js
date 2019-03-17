import { module, test } from 'qunit';
import { visit, currentURL, fillIn, click, find, waitFor, findAll } from '@ember/test-helpers';
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

  test('register link works', async function(assert) {
    await visit('/auth/login');
    const registerLink = findAll('a').find((element) => {
      return element.textContent.trim() === 'Don\'t have an account yet?';
    });
    await click(registerLink);
    assert.equal(currentURL(), '/auth/register');
  });

  test('forgotten password link works', async function(assert) {
    await visit('/auth/login');
    const passwordLink = findAll('a').find((element) => {
      return element.textContent.trim() === 'password';
    });
    await click(passwordLink);
    assert.equal(currentURL(), '/auth/forgot/password');
  });

  test('forgotten username link works', async function(assert) {
    await visit('/auth/login');
    const usernameLink = findAll('a').find((element) => {
      return element.textContent.trim() === 'username';
    });
    await click(usernameLink);
    assert.equal(currentURL(), '/auth/forgot/username');
  });
});
