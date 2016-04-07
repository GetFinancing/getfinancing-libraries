% include('header.tpl', title='Create Loan Application')

<div class="row">
    <div class="col-lg-12">
        <h1>Create Loan Application</h1>

        <p>The following request will be sent as JSON. Please see <code>def create_loan_application</code> in
        <code>getfinancing.py</code> for more details.</p>

        <pre>{
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
}</pre>

        <p><button id="send">Send request</button></p>

        <div id="loading" class="hidden">
            <i class="fa fa-spinner fa-spin fa-5x"></i>
        </div>

        <div id="result_wrapper" class="hidden">
            <p>Result:</p>
            <pre id="result"></pre>
            <button id="open_application">Open Loan Application</button>
            <p>When you click "Open Loan Application" <code>new GetFinancing()</code> is called with the application URL
            as a parameter and 2 JavaScript event handlers which are called on success or on abort.
            The <code>GetFinancing</code> object is loaded in advance from
            <code>https://partner.getfinancing.com/libs/1.0/getfinancing.js</code>.
            Please see the source code of this page for more details.</p>
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
