class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, ExpenseClaim, user_id: user.id
    can :manage, ExpenseEntry, user_id: user.id
  end
end
