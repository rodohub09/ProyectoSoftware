enum Enumfiltros {
  tecnologia('Tecnologia'),
  vestimenta('Vestimenta'),
  accesorios('Accesorios'),
  documentos('Documentos'),
  utiles('Utiles'),
  miscelaneos('Misceláneos');

  final String label;
  const Enumfiltros(this.label);
}

const Map<Enumfiltros,List<String>> subfiltros = {
  Enumfiltros.tecnologia: ['Celular','Audífono','Cargador','Tablet','Otros'],
  Enumfiltros.vestimenta: ['Chaqueta','Polerón','Calzado','Polera','Bufanda','Otros'],
  Enumfiltros.accesorios: ['Reloj','Gorro','Pulsera','Collar','Lentes','Otros'],
  Enumfiltros.documentos: ['TNE','Carnet','Tarjeta Bancaria','Otros'],
  Enumfiltros.utiles: ['Estuche','Cuaderno','Lápiz','Otros'],
  Enumfiltros.miscelaneos: ['Billetera','Termo','Mochila','Balón','Otros']
};

