Math = {}

-- Get distance between two entities
function Math.GetDistance(a, b)
  return math.sqrt((a:GetX() - b:GetX()) ^ 2 + (a:GetY() - b:GetY()) ^ 2 + (a:GetZ() - b:GetZ()) ^ 2)
end

return Math
