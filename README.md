---
languages: ruby
tags: rails, full application, associations
---

# Auction App

## Description

We're going to make our own eBay clone. Yeah, *that* eBay. While the site is certainly a pretty big deal, it still just boils down to yet another MVC (Model, View, Controller) web app that processes form submissions. Really.

In this lab, we're going to create a basic version of an auction site.

## Instructions

### Part 1

* Create an auction (should have an end_time, title, description, and price)
* See a list of auctions
* View an auction
* Edit an auction
* End an auction (making sure to destroy all bids)
* Only show active auctions on the show page
* Place a bid on an auction (must be higher than the current bid, must be an active auction)
* Associations between Auctions, Users, and Bids
* View all bids on an auction

### Bonus 1

* Add the concept of sessions
* Disallow lister from bidding on their own auction

### Bonus 2

* Add authentication to editing/ending an auction
* Add the ability to upload a photo