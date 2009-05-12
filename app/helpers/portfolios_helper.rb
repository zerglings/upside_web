module PortfoliosHelper
  def portfolio_to_xml_builder(parent_node, portfolio)
    parent_node.portfolio do |output|
      output.cash portfolio.cash
    end
  end
  
  def portfolio_to_json_hash(portfolio)
    {
      :cash => portfolio.cash
    }
  end
  
  def position_to_xml_builder(parent_node, position)
    parent_node.position do |output|
      output.model_id position.id
      output.ticker position.stock.ticker
      output.quantity position.quantity
      output.is_long position.is_long
    end
  end
  
  def position_to_json_hash(position)
    {
      :model_id => position.id,
      :ticker => position.stock.ticker,
      :quantity => position.quantity,
      :is_long => position.is_long
    }
  end

  def portfolio_stat_to_xml_builder(parent_node, stat)
    parent_node.portfolio_stat do |output|
      output.model_id stat.id
      output.frequency stat.frequency_string
      output.rank stat.rank
      output.net_worth stat.net_worth
    end
  end
  
  def portfolio_stat_to_json_hash(stat)
    {
      :model_id => stat.id,
      :frequency => stat.frequency_string,
      :rank => stat.rank,
      :net_worth => stat.net_worth
    }
  end
end
