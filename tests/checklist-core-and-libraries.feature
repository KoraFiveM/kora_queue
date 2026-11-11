# Converted from the communitybot legacy tests by kora-qa-panel/scripts/convert-legacy.mjs.
# The """ block under each Scenario is the original test text, verbatim. Review before applying.
Feature: kora_queue — Core & Libraries

  @kora_queue @checklist @checklist:kora_queue:queue-card @cat:core-and-libraries @manual
  Scenario: Connection queue card
    """
    Checklist test: When the server is full, connecting players see the 'Kora' adaptive card with name, position, queue size, time and status.
    """
    When I manually: ask a second player to fill the server to capacity, then connect as a new player
    Then I confirm: the connecting player sees the 'Kora' adaptive card
    And I confirm: the card shows name, position, queue size, time and status

  @kora_queue @checklist @checklist:kora_queue:queue-position @cat:core-and-libraries @manual
  Scenario: Position updates and auto-join
    """
    Checklist test: Waiting players see position (e.g. 3/5) update, then 'Joining...' and connect automatically when a slot opens.
    """
    When I manually: connect to a full server and wait in the queue
    Then I confirm: my position (e.g. 3/5) updates as players ahead leave
    When I manually: ask a second player to free a slot by disconnecting
    Then I confirm: the card shows 'Joining...'
    And I confirm: I connect to the server automatically

  @kora_queue @checklist @checklist:kora_queue:priority @cat:core-and-libraries @manual
  Scenario: Priority players skip ahead
    """
    Checklist test: An identifier in Config.Priority / Queue.AddPriority is placed ahead of normal players (shown as priority on the card).
    """
    When I manually: ask a second player to connect with a normal identifier to a full server, then connect with an identifier listed in Config.Priority or added via Queue.AddPriority
    Then I confirm: I am placed ahead of the normal players in the queue (only applies when a priority identifier is configured; otherwise mark Pass if nothing is configured)
    And I confirm: the card shows I have priority

  @kora_queue @checklist @checklist:kora_queue:join-delay @cat:core-and-libraries @manual
  Scenario: 30s startup join delay
    """
    Checklist test: After a resource start, connecting players wait in queue ~30s before admission so other resources can initialise.
    """
    When I manually: ask an admin to restart the kora_queue resource, then connect immediately
    Then I confirm: I wait in the queue for about 30 seconds before being admitted

  @kora_queue @checklist @checklist:kora_queue:timeouts @cat:core-and-libraries
  Scenario: Queue and connect timeouts
    """
    Checklist test: A player who stops responding is dropped from the queue after ~90s; connecting players time out after 10 min.
    """
    When I manually: join the queue, then stop the game client from responding without closing it
    And I wait 100 seconds
    Then I confirm: I am dropped from the queue after about 90 seconds
    When I manually: connect and stay in the connecting state without finishing loading for 10 minutes
    Then I confirm: the connecting player times out after about 10 minutes

  @kora_queue @checklist @checklist:kora_queue:whitelist-steam @cat:core-and-libraries @manual
  Scenario: Optional steam / priority-only modes
    """
    Checklist test: If Config.RequireSteam or PriorityOnly is enabled, non-steam/non-priority players get the error message (both off by default).
    """
    When I manually: try to connect without Steam running, or without priority when PriorityOnly is on
    Then I confirm: I get the error message and cannot join (only applies when Config.RequireSteam or Config.PriorityOnly is enabled; both off by default, otherwise mark Pass if nothing happens)
