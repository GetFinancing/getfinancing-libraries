import argparse
import bottle
from bottle import get, run, view, route, static_file, HTTPError, request
from httplib import INTERNAL_SERVER_ERROR
from requests import post, codes
import json

HOSTNAME = "api1-test-pre.getfinancing.com:10001"
MERCHANT_ID = "gf90c16012b52cd88ef2463befac03219c"
USERNAME = "cdx_demogetfinancing"
PASSWORD = "OhG4ua^H"

"""
HOSTNAME = "api-test.getfinancing.com"
USERNAME = "ws_Credex_sub"
PASSWORD = "zo3FeiR`"
"""

HEADERS = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

LOAN_APPLICATION_REQUEST = {
    "merchant_loan_id": "ACMECORP1055",
    "amount": "1001.99",
    "first_name": "John",
    "last_name": "Doe",
    "shipping_address":
        {"street1":"4269 Deeboyer av","city":"Lakewood","state":"CA","zipcode":"90712"},
    "billing_address":
        {"street1":"4269 Deeboyer av","city":"Lakewood","state":"CA","zipcode":"90712"},
    "cart_items": [
        {"sku":"foo", "display_name":"fubar", "quantity":1, "unit_price": "1001.99", "unit_tax": "50.00"}
    ],
    "email": "johndoe@example.com",
    "version":"1.9",
}


def create_loan_application(data, merchant_id, hostname, username, password, test=False):
    """Creates a loan application.

    Example response:
    {
        u'amount': u'1001.99',
        u'href': u'https://partner-test.getfinancing.com/partner-test/lc/info/4c5288b746bf22325f8abaafa83b119d',
        u'inv_id': u'4c5288b746bf22325f8abaafa83b119d'
    }
    """
    url = "https://%s/merchant/%s/requests" % (hostname, merchant_id)
    verify = not test
    response = post(url, json.dumps(data), auth=(username, password), headers=HEADERS, verify=verify)
    if response.status_code != codes.ok:
        raise RuntimeError('Creating loan application failed, HTTP code: %s, message: %s' %
                           (response.status_code, response.text))

    return json.loads(response.text)

@route('/static/<path:path>')
def callback(path):
    return static_file(path, 'static')

@get('/')
@view('index')
def view_index():
    """Index page listing all possible test actions."""
    return {}

@get('/create_loan_application')
@view('create_loan_application')
def view_create_loan_application():
    """View the create loan application page."""
    return {}

@route('/ajax/create_loan_application', method='POST')
def ajax_create_loan_application():
    """AJAX handler to create loan application page."""
    try:
        return create_loan_application(LOAN_APPLICATION_REQUEST, MERCHANT_ID, HOSTNAME, USERNAME, PASSWORD, test=True)
    except Exception as e:
        return HTTPError(INTERNAL_SERVER_ERROR, e)


@get('/loan_status_postbacks')
@view('loan_status_postbacks')
def view_loan_status_postbacks():
    """View the loan status postbacks page."""
    postback_url = "http://%s:%d/getfinancing/postbacks" % (args.hostname, args.port)
    return locals()

@route('/ajax/loan_status_postback', method='POST')
def ajax_loan_status_postback():
    """AJAX handler that sends a loan status postback."""
    response = post(request.POST['url'], request.POST['request'])
    if response.status_code != codes.ok:
        return HTTPError(INTERNAL_SERVER_ERROR, 'Error sending postback, HTTP code: %s, message: %s' %
                           (response.status_code, response.text))

    return response.text

@route('/getfinancing/postbacks', method='POST')
def handle_postback():
    """Handles a postback."""
    return '1'

def run_server(hostname, port):
    """Runs an HTTP server on the specified port in order to listen for postbacks."""
    print '\n\n\n'
    print '============================================================================================================'
    print 'Please open your browser and point it to http://%s:%d in order to access the GetFinancing tests' % \
          (hostname, port)
    print '============================================================================================================'
    print '\n\n\n'
    bottle.debug(True)
    run(host=hostname, port=port)

def send_postback(url):
    """Sends a postback to the test HTTP server listening on localhost on the specified TCP port.

    This method is used ONLY for testing purposes, in a production scenario the postbacks will be sent to you
    by the GetFinancing servers.
    """
    data = {}
    response = post(url, json.dumps(data))
    if response.status_code != codes.ok:
        raise RuntimeError('Creating loan application failed, HTTP code: %s, message: %s' %
                           (response.status_code, response.text))

    response_data = json.loads(response.text)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='GetFinancing testing library.')
    parser.add_argument('--hostname', default='localhost',
                        help='HTTP hostname to bind test web server to,' +
                             'use 0.0.0.0 if you want to make it accessible from other computers')
    parser.add_argument('--port', type=int, default=8080, help='HTTP port for test web server')
    args = parser.parse_args()
    run_server(args.hostname, args.port)
