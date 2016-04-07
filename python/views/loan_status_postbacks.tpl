% include('header.tpl', title='Loan Status Postbacks')

<div class="row">
    <div class="col-lg-12">
        <h1>Loan Status Postbacks</h1>

        <form id="postback">
            <div class="row">
                <div class="form-group col-md-12">
                <label class="sr-only" for="loan_id">Loan ID</label>
                <input class="form-control input-lg" type="text" name="loan_id" id="loan_id" placeholder="Loan ID" value="4c5288b746bf22325f8abaafa852913b" required>
                </div>

                <div class="form-group col-md-12">
                <label class="sr-only" for="type">Postback Type</label>
                <select name="type" id="type">
                    <option value="approved">Approved</option>
                    <option value="preapproved">Preapproved</option>
                    <option value="rejected">Rejected</option>
                </select>
                </div>

                <div class="form-group col-md-12">
                <label class="sr-only" for="postback_url">Postback URL</label>
                <input class="form-control input-lg" type="text" name="postback_url" id="postback_url" placeholder="Postback URL" value="{{ postback_url }}" required>
                </div>
            </div>
        </form>

        <p>Send the following JSON request:</p>
        <pre id="request"></pre>

        <p><button id="send">Send request</button></p>

        <div id="loading" class="hidden">
            <i class="fa fa-spinner fa-spin fa-5x"></i>
        </div>

        <div id="result_wrapper" class="hidden">
            <p>Result:</p>
            <pre id="result"></pre>
        </div>

    </div>
</div>

<script>
var update_request = function() {
    var type = $("#type").val();
    if (type == 'approved') {
        request = '{"request_token":"ORDER_ID","merchant_transaction_id":"ACMECORP1055","updates":{"status":"approved"},"version":"1.9"}';
    } else if (type == 'preapproved') {
        request = '{"request_token":"ORDER_ID","merchant_transaction_id":"ACMECORP1055","updates":{"status":"preapproved"},"version":"1.9"}';
    } else if (type == 'rejected') {
        request = '{"request_token":"ORDER_ID","merchant_transaction_id":"ACMECORP1055","updates":{"status":"rejected"},"version":"1.9"}';
    }

    request = request.replace('ORDER_ID', $("#loan_id").val());
    $("#request").text(request);
}

$("#type").change(update_request);
$("#loan_id").change(update_request);
$("#type").change();

$("#send").click(function() {
    $("#loading").removeClass("hidden");
    $("#result_wrapper").addClass("hidden");

    var data = {
        'url': $("#postback_url").val(),
        'request': $("#request").text()
    }

    $.ajax({
        url: "/ajax/loan_status_postback",
        method: "POST",
        data: data,
        success: function(data) {
            $("#result").text(JSON.stringify(data, null, '\t'));
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
