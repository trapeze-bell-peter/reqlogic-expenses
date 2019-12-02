# frozen_string_literal: true

# Defines ability of user to manage objects - cancancan class
class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, ExpenseClaim, user_id: user.id
    can :manage, ExpenseEntry, user_id: user.id
    can(:manage, Receipt) { |receipt| receipt.expense_entry.user_id == user.id }
  end
end
