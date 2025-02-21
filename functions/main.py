import stripe
import firebase_admin
from firebase_admin import firestore
from flask import jsonify
from firebase_functions import https

firebase_admin.initialize_app()

STRIPE_SECRET_KEY = "sk_test_51Q3juAH1XCaiLE9lrMm5gnGDe2MIOzs1ZTPOVNGKGsCbcOCHZaAkpEEeTyryhvHA373yajvj8ruRRlKJGlpu0vlE00FVhnos8x"  
stripe.api_key = STRIPE_SECRET_KEY

@https.on_request()
def create_payment_intent(request):
    try:
        request_json = request.get_json()
        amount = request_json.get("amount", 1000)  # Default to $10 (1000 cents)
        currency = request_json.get("currency", "usd")

        # Create PaymentIntent
        payment_intent = stripe.PaymentIntent.create(
            amount=amount,
            currency=currency,
            payment_method_types=["card"]
        )

        return jsonify({"client_secret": payment_intent.client_secret}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
