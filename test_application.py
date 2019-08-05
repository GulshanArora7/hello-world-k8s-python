#!/usr/bin/env python3
import unittest
import hello_world

class TestHello(unittest.TestCase):

    def setUp(self):
        hello_world.app.testing = True
        self.app = hello_world.app.test_client()

    def test_hello(self):
        rv = self.app.get('/')
        self.assertEqual(rv.status, '200 OK')
        self.assertEqual(rv.data, b'Hello World!\n')

    def test_healthcheck(self):
        rv = self.app.get('/health')
        self.assertEqual(rv.status, '200 OK')
        self.assertEqual(rv.data, b'OK')



if __name__ == '__main__':
    unittest.main()


