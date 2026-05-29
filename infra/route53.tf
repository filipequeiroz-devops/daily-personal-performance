# Aponta o seu subdomínio para a distribuição CloudFront que acabamos de criar.
resource "aws_route53_record" "daily_personal_performance_cname" {
  # O ID da zona hospedada do seu domínio principal (ex: filipe-deabreu.com)
  zone_id = data.aws_route53_zone.meu_dominio.zone_id
  # O nome do subdomínio que você quer usar (ex: daily-personal-perfomance)
  name    = "daily-personal-perfomance"
  # Tipo A é para endereços IPv4, mas com o Alias, o Route53 resolve magicamente para o IP do CloudFront
  type    = "A"

  # A mágica do Alias: em vez de um IP, apontamos para outro recurso da AWS
  alias {
    # O domínio da distribuição CloudFront
    name                   = aws_cloudfront_distribution.daily_personal_performance_distribution.domain_name
    # A "zona hospedada" interna do CloudFront (este valor é sempre o mesmo para CloudFront)
    zone_id                = aws_cloudfront_distribution.daily_personal_performance_distribution.hosted_zone_id
    # Importante para o Route53 saber se deve ou não esperar a saúde do alvo
    evaluate_target_health = false
  }
}
