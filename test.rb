require 'net/http'
require 'uri'
require 'json'

def process_document client_dni, debtor_dni, document_amount, folio, expiration_date
    uri = URI.parse("https://chita.cl/api/v1/pricing/simple_quote?client_dni=#{client_dni}&debtor_dni=#{debtor_dni}&document_amount=#{document_amount}&folio=#{folio}&expiration_date=#{expiration_date}")
    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = "pZX5rN8qAdgzCe0cAwpnQQtt"

    req_options = {
        use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end
    data = JSON.parse(response.body)

    document_rate = data["document_rate"]
    commission = data["commission"]
    advance_percent = data["advance_percent"]

    cost = (document_amount * (advance_percent/100) * ((document_rate/100) / 30 * 31) ).to_i
    draft_amount = ((document_amount * (advance_percent/100)) - (cost + commission)).to_i
    surplus = (document_amount - (document_amount * (advance_percent/100))).to_i


    puts "Costo de financiamiento: $#{cost}"
    puts "Giro a recibir: $#{draft_amount}"
    puts "Excedentes: $#{surplus}"

    return {
        cost: cost,
        draft_amount: draft_amount,
        surplus: surplus
    }

end 


client_dni = "76329692-K"
debtor_dni = "77360390-1"
document_amount = 1000000
folio = 75
expiration_date = "2024-02-03"

process_document(client_dni, debtor_dni, document_amount, folio, expiration_date)
