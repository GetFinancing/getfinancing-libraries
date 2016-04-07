% include('header.tpl', title='Create Loan Application')

<div class="row">
    <div class="col-lg-12">
        <h1>Create Loan Application</h1>

        <pre>from requests import post, codes
import json

HOSTNAME = "api-test.getfinancing.com"
USERNAME = "ws_Credex_sub"
PASSWORD = "zo3FeiR`"
MERCHANT_ID = "gf90c16012b52cd88ef2463befac03219c"

HEADERS = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
}

LOAN_APPLICATION_REQUEST = {
    "merchant_loan_id": "ACMECORP1055", # optional loan id on the merchant side
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

create_loan_application(LOAN_APPLICATION_REQUEST, MERCHANT_ID, HOSTNAME, USERNAME, PASSWORD)
</pre>

        <p><button id="send">Send request</button></p>

        <div id="loading" class="hidden">
            <i class="fa fa-spinner fa-spin fa-5x"></i>
        </div>

        <div id="result_wrapper" class="hidden">
            <p>Result:</p>
            <pre id="result"></pre>
            <button id="open_application">Open Loan Application</button>
        </div>

    </div>
</div>

<script type="text/javascript" src="https://partner.getfinancing.com/libs/1.0/getfinancing.js"></script>
<script>
var onComplete = function() {
    // this is called when the user finishes all the steps and
    // gets loan preapproved
    alert('Loan is preapproved');
};

var onAbort = function() {
    // this is called when the user finishes all the steps and
    // gets loan preapproved
    alert('Loan was aborted');
};

$("#send").click(function() {
    $("#loading").removeClass("hidden");
    $("#result_wrapper").addClass("hidden");

    $.ajax({
        url: "/ajax/create_loan_application",
        success: function(data) {
            $("#result").text(JSON.stringify(data, null, '\t'));
            $("#open_application").click(function() { new GetFinancing(data.href, onComplete, onAbort) });
            $("#result_wrapper").removeClass("hidden");
            $("#loading").addClass("hidden");
        },
        error: function(data) {
            $("#loading").addClass("hidden");
            alert('An error occurred while sending the request. Details:\n\n' + data);
        }
    })
});

</script>

% include('footer.tpl')
