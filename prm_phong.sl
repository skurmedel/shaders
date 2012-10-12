surface
normal_mapped(
	string diffuse_map = "";
	string specular_map = "";
	float exponent = 2.0;
) {
	N = faceforward(normalize(N), I);

	color diffuse_col = texture(diffuse_map);
	color spec_col 	  = texture(specular_map);

	illuminance("*", P)
	{
		vector nL = normalize(L);
		color diffuse_term = N.nL * (Cl * diffuse_col) ;

		vector R = reflect(nL, N);
		color spec_term = pow(max(0.0, R.normalize(I)), exponent) * spec_col * Cl;

		Ci += diffuse_term + spec_term;
	}
}	