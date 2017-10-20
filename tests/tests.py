import unittest

import testdocker
from testdocker import (
    ContainerTestMixinBase,
    ContainerTestMixin,
    CommandBase,
    CurlCommand,
    NetCatCommand,
    CatCommand,
    Container
)


# class SupCommand(CommandBase):
#     def __init__(self, module, function, *args):
#         cmd = ['sup']
#         cmd.append(module)
#         cmd.append(function)
#         if args:
#             cmd.extend(args)
#         self.cmd = ' '.join(cmd)


# def select_one(iterable, where, equals):
#     for item in iterable:
#         if getattr(item, where, None) == equals:
#             return item
#             break


# def ensure_account_created(containers):
#     kazoo = select_one(containers, where='name', equals='kazoo')
#     cmd = SupCommand('crossbar_maintenance', 'find_account_by_name', 'test')
#     exit_code, output = kazoo.exec(cmd)
#     if exit_code == 0 and '{error,not_found}' in output:
#         cmd = SupCommand('crossbar_maintenance', 'create_account', 'test', 'localhost', 'admin', 'secret')
#         exit_code, output = kazoo.exec(cmd)
#         assert exit_code == 0


class TestContainer(ContainerTestMixin, unittest.TestCase):
    """
    Test monster-ui container.

    Attributes:
        name:
            (str) Name for container.
        tear_down:
            (bool) Should ``docker-compose down`` be run in ``tearDownClass?``.
        compose_files:
            (list) List of docker-compose files to load for testing.
        test_patterns:
            (list) Regex patterns to assert in  container logs.
        test_tcp_ports:
            (list) TCP Ports to assert are open
        test_upd_ports:
            (list) TCP Ports to assert are open
        test_http_uris:
            (list) HTTP URI's to test are reachable
    """
    name = 'monster-ui'
    tear_down = False
    test_patterns = [
        r'Starting nginx'
    ]
    test_tcp_ports = [80]
    test_upd_ports = []
    test_http_uris = [
        'http://localhost',
        'http://localhost/js/config.js'
    ]

    def test_config_js_is_correct(self):
        """Assert config.js has correct information"""
        cmd = CatCommand('/var/www/html/monster-ui/js/config.js')
        exit_code, output = self.container.exec(cmd)
        self.assertEqual(exit_code, 0)

        config_assert_regex = (
            r"default: '{}',".format(
                self.container.env['MONSTERUI_CROSSBAR_URI']),
            r"socket: '{}',".format(
                self.container.env['MONSTERUI_WEBSOCKET_URI']),
            r"socketWebphone: '{}',".format(
                self.container.env['MONSTERUI_WEBPHONE_URI']),
            r"phonebook: ''",
            r"disableBraintree: {},".format(
                self.container.env['MONSTERUI_DISABLE_BRAINTREE']),
            r"applicationTitle: 'Valuphone, Inc',",
            r"callReportEmail: 'support@valuphone.com',",
            r"companyName: 'Valuphone',",
            r"help: '//support.valuphone.com',",
            r"logout: '/'",
            r"preventDIDFormatting: false,",
            r"showAllCallflows: true,",
            r"showJSErrors: {}".format(
                self.container.env['MONSTERUI_SHOW_JS_ERRORS'])
        )
        for regex in config_assert_regex:
            with self.subTest(regex=regex):
                self.assertRegex(output, regex)

    def test_nginx_conf_is_correct(self):
        """Assert nginx.conf has correct information"""
        cmd = CatCommand('/etc/nginx/nginx.conf')
        exit_code, output = self.container.exec(cmd)
        self.assertEqual(exit_code, 0)

        config_assert_regex = (
            r"error_log           /dev/stderr {};".format(
                self.container.env['NGINX_LOG_LEVEL']),
            r"client_max_body_size        {};".format(
                self.container.env['NGINX_HTTP_CLIENT_MAX_BODY_SIZE'])
        )
        for regex in config_assert_regex:
            with self.subTest(regex=regex):
                self.assertRegex(output, regex)

    def test_index_html_seems_correct(self):
        """Assert index.html seems correct"""
        cmd = CurlCommand('http://localhost')
        exit_code, output = self.container.exec(cmd)
        self.assertEqual(exit_code, 0)
        self.assertRegex(output, r'js/main.js')


if __name__ == '__main__':
    testdocker.main()
