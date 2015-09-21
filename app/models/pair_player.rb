class PairPlayer < Player

  def self.find_or_create_by_users(user1, user2)
    PairPlayer.find_or_create_by(username: concatenate_and_order_usernames(user1, user2))
  end

  def self.concatenate_and_order_usernames(username1, username2)
    usernames = [username1, username2]
    "#{usernames.min} #{usernames.max}"
  end

  def ids_from_username
    username.split
  end

  def member_name(members)
    username1, username2 = self.ids_from_username

    member = members.detect{ |m| m["id"] == username1 }
    name1 = member.present? ? member["name"] : "unknown"

    member = members.detect{ |m| m["id"] == username2 }
    name2 = member.present? ? member["name"] : "unknown"

    "#{name1} et #{name2}"
  end
end
