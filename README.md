# Identity::Freshdesk
Short description and motivation.

## Usage
How to use my plugin.

### Rules

`options.default_mailing_from_email` is assumed to be the FD email.


```yaml
freshdesk:
  api_token: API123TOKEN3FROM432ADMIN
  subdomain: akcjademokracja
  rules:
    - 
    
```

## Technical details

1. `/freshdesk/webhook` receives a JSON POST from FD rule. It should contain `id`, `triggered_event`

2. Ticket data is fetched

3. Requester is mapped to member

4. Rules are run on the ticket and requester

5. The results are updated on the ticket


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'identity-freshdesk'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install identity-freshdesk
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

